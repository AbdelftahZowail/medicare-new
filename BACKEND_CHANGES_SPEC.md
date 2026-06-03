# Backend Changes Spec — Closing the Report Gaps (Excluding AI Chatbot & Social Login)

> Companion to `OVERALL_STATUS_REPORT.md`.  
> This document is a **spec only** — it does not modify the running backend (which lives elsewhere). Apply these changes to the local `medicare-backend` codebase when the team is ready to ship the next backend release.
>
> **Out of scope:** AI Chatbot, Social Login (Google/Apple/Facebook).

---

## 1. Items That Need Backend Changes

| # | Item | File(s) Affected | Effort | Notes |
|---|------|------------------|--------|-------|
| 1 | Geospatial search — Clinics | `ClinicController.cs`, `IClinicService.cs`, `ClinicService.cs`, new DTO | M | New endpoint `GET /api/clinic/nearby` |
| 2 | Geospatial search — Doctors | `DoctorController.cs`, `IDoctorService.cs`, `DoctorService.cs`, new DTO | M | New endpoint `GET /api/doctor/nearby` |
| 3 | Add `Latitude`/`Longitude` to `DoctorProfileDto` | `DoctorDtos.cs`, `DoctorService.cs` | XS | Needed to show a doctor pin on the map from the profile screen |
| 4 | Add `PatientCount` to `DoctorProfileDto` | `DoctorDtos.cs`, `DoctorService.cs` | XS | The Figma profile shows a "Patients count" stat |
| 5 | Distance field on Doctor list | `DoctorDtos.cs`, `DoctorService.cs` | XS | Add `DistanceKm` to `DoctorListItemDto` so the browse list can show "1.2 km away" |
| 6 | Seed sample lat/lng for clinics in `DbSeeder` | `Data/DbSeeder.cs` | XS | Without this, the seeded clinics won't appear on the map |
| 7 | Structured prescription (optional, scope creep) | `MedicalRecord.cs` (new entity), migration, DTOs, services | L | Current JSON-in-text approach works but is hacky. Defer unless Flutter really needs to query meds. |

---

## 2. Detailed Change Specs

### 2.1 New Endpoint: `GET /api/clinic/nearby` (Geospatial Clinic Search)

**Purpose:** Power the Figma "Nearby" map screen. Returns clinics within a radius of a lat/lng, ordered by distance.

**Route:** `GET /api/clinic/nearby?lat={double}&lng={double}&radiusKm={double=5}&specialization={string?}&search={string?}`
- `lat`, `lng` — required, the user's location (or device GPS).
- `radiusKm` — optional, default `5`.
- `specialization` — optional, filters clinics that have at least one doctor with this specialty.
- `search` — optional, name/area contains match (same as existing `GET /api/clinic`).

**Auth:** Public (no `[Authorize]`) — same as `GET /api/clinic`.

**Response DTO:** New `NearbyClinicDto` in `DTOs/Clinic/ClinicDtos.cs`:

```csharp
public class NearbyClinicDto : ClinicDto
{
    public double DistanceKm { get; set; }
    public int MatchingDoctorsCount { get; set; } // doctors matching the specialization filter
}
```

**Distance formula:** Haversine in C#. No new package, no SQL spatial type, no schema change. Cheap for the dataset size.

Add helper to `Helpers/GeoUtils.cs` (new file):

```csharp
namespace MedicalApp.API.Helpers;

public static class GeoUtils
{
    private const double EarthRadiusKm = 6371.0088;

    public static double HaversineKm(double lat1, double lon1, double lat2, double lon2)
    {
        var dLat = ToRad(lat2 - lat1);
        var dLon = ToRad(lon2 - lon1);
        var a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2)
              + Math.Cos(ToRad(lat1)) * Math.Cos(ToRad(lat2))
              * Math.Sin(dLon / 2) * Math.Sin(dLon / 2);
        var c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
        return EarthRadiusKm * c;
    }

    private static double ToRad(double deg) => deg * (Math.PI / 180.0);
}
```

**Service implementation** in `IClinicService` / `ClinicService`:

```csharp
// In IClinicService
Task<ApiResponse<List<NearbyClinicDto>>> GetNearbyClinicsAsync(
    double lat, double lng, double radiusKm = 5,
    string? specialization = null, string? search = null);

// In ClinicService.cs — implementation sketch
public async Task<ApiResponse<List<NearbyClinicDto>>> GetNearbyClinicsAsync(
    double lat, double lng, double radiusKm = 5,
    string? specialization = null, string? search = null)
{
    var query = _unitOfWork.Clinics.Query()
        .Include(c => c.DoctorClinics).ThenInclude(dc => dc.Doctor)
        .Where(c => c.IsActive && c.Latitude != null && c.Longitude != null);

    if (!string.IsNullOrEmpty(search))
        query = query.Where(c => c.Name.Contains(search)
            || (c.Government != null && c.Government.Contains(search))
            || (c.Area != null && c.Area.Contains(search)));

    if (!string.IsNullOrEmpty(specialization))
        query = query.Where(c => c.DoctorClinics.Any(dc =>
            dc.IsActive && dc.Doctor.Specialization == specialization));

    var clinics = await query.ToListAsync();

    var result = clinics
        .Select(c => new NearbyClinicDto
        {
            // copy all ClinicDto fields via manual mapping or AutoMapper projection
            Id = c.Id, Name = c.Name, /* ... */
            Latitude = c.Latitude, Longitude = c.Longitude,
            DistanceKm = GeoUtils.HaversineKm(lat, lng, c.Latitude!.Value, c.Longitude!.Value),
            MatchingDoctorsCount = c.DoctorClinics.Count(dc =>
                dc.IsActive && (specialization == null || dc.Doctor.Specialization == specialization))
        })
        .Where(c => c.DistanceKm <= radiusKm)
        .OrderBy(c => c.DistanceKm)
        .ToList();

    return ApiResponse<List<NearbyClinicDto>>.Success(result);
}
```

**Controller** in `ClinicController.cs` — add this route **before** the `{id}` route (otherwise `nearby` will be parsed as an id and 404):

```csharp
[HttpGet("nearby")]
public async Task<IActionResult> GetNearby(
    [FromQuery] double lat,
    [FromQuery] double lng,
    [FromQuery] double radiusKm = 5,
    [FromQuery] string? specialization = null,
    [FromQuery] string? search = null)
{
    var result = await _clinicService.GetNearbyClinicsAsync(lat, lng, radiusKm, specialization, search);
    return StatusCode(result.StatusCode, result);
}
```

> ⚠️ **Route ordering matters.** The existing `[HttpGet("{id}")]` will swallow `nearby` unless `nearby` is declared first. ASP.NET Core resolves routes by declaration order within a controller, so put `GetNearby` above `GetById`.

---

### 2.2 New Endpoint: `GET /api/doctor/nearby` (Geospatial Doctor Search)

**Purpose:** Power the same map screen, but plot doctors instead of clinics. Doctor location is taken from their *active* clinic (per existing pattern in `DoctorService.GetAllDoctorsAsync` line 115-120).

**Route:** `GET /api/doctor/nearby?lat={double}&lng={double}&radiusKm={double=5}&specialization={string?}&search={string?}`

**Auth:** Public.

**Response DTO:** New `NearbyDoctorDto` in `DTOs/Doctor/DoctorDtos.cs`:

```csharp
public class NearbyDoctorDto : DoctorListItemDto
{
    public double DistanceKm { get; set; }
    public int? ClinicIdForLocation { get; set; }
}
```

**Service implementation** in `IDoctorService` / `DoctorService.cs`. The pattern is identical to the clinic version:

1. Query doctors with at least one active `DoctorClinic` whose `Clinic.Latitude` and `Clinic.Longitude` are non-null.
2. For each doctor, compute distance from the *first* active clinic with coords (or expose `ClinicIdForLocation` so the client can compute it from any clinic).
3. Filter by `radiusKm`, order by `DistanceKm`.

> ℹ️ **Design note:** A doctor can be linked to multiple clinics with different lat/lngs. For v1, using the first active clinic is fine. If you want to show "this doctor works at 3 nearby clinics", you can later add `GET /api/clinic/nearby?doctorId=X` and merge in the Flutter client.

---

### 2.3 Add `Latitude`/`Longitude` to `DoctorProfileDto`

**Why:** The `GET /api/doctor/{id}` endpoint returns `DoctorProfileDto`, which does **not** currently include coordinates. Without this, the Flutter profile screen can't plot the doctor on a map.

**File:** `DTOs/Doctor/DoctorDtos.cs`

Add to `DoctorProfileDto` (after line 23 `public string? ClinicName`):

```csharp
public double? ClinicLatitude { get; set; }
public double? ClinicLongitude { get; set; }
public int? ClinicGovernmentId { get; set; } // optional, for "city" display
```

> Note: naming it `ClinicLatitude` (not `Latitude`) makes it clear this is the *clinic's* coordinate, since doctors themselves don't have one. The Flutter side can use the existing `DoctorListItemDto` pattern but for the detail view.

**File:** `Services/Implementations/DoctorService.cs`

In both `GetDoctorByIdAsync` (line 174) and `GetProfileAsync` (line 216), populate these fields from `activeClinic`:

```csharp
// Existing code (around line 206-211)
var activeClinic = doctor.DoctorClinics.FirstOrDefault(dc => dc.IsActive)?.Clinic;
if (activeClinic != null)
{
    dto.ClinicId = activeClinic.Id;
    dto.ClinicName = activeClinic.Name;
    // ADD:
    dto.ClinicLatitude = activeClinic.Latitude;
    dto.ClinicLongitude = activeClinic.Longitude;
}
```

> Apply this in both `GetDoctorByIdAsync` and `GetProfileAsync` (they share the same mapping block).

---

### 2.4 Add `PatientCount` to `DoctorProfileDto`

**Why:** Figma shows "Patients: 250+" on the doctor profile. The backend has `TotalReviews` but no total patients seen. The most useful definition: distinct patient IDs (or `OfflinePatientPhone`s) that have a non-cancelled appointment with this doctor.

**File:** `DTOs/Doctor/DoctorDtos.cs` — add to `DoctorProfileDto`:

```csharp
public int TotalPatients { get; set; }  // distinct patients seen (all time)
```

**File:** `Services/Implementations/DoctorService.cs` — in `GetDoctorByIdAsync` and `GetProfileAsync`, before returning:

```csharp
dto.TotalPatients = await _unitOfWork.Appointments.Query()
    .Where(a => a.DoctorId == doctor.Id && a.Status != AppointmentStatus.Cancelled)
    .Select(a => a.PatientId ?? -a.OfflinePatientPhone.GetHashCode()) // null-safe distinct
    .Distinct()
    .CountAsync();
```

> **Caveat:** The `.Select(a => a.PatientId ?? -a.OfflinePatientPhone.GetHashCode())` is a quick-and-dirty distinct that conflates phone hash collisions. For a real system, add a computed column or use a UNION of PatientIds and Phone strings. For the v1 fix, just count distinct `PatientId` non-null and ignore offline:

```csharp
// Simpler & safer:
dto.TotalPatients = await _unitOfWork.Appointments.Query()
    .Where(a => a.DoctorId == doctor.Id
             && a.PatientId != null
             && a.Status != AppointmentStatus.Cancelled)
    .Select(a => a.PatientId!.Value)
    .Distinct()
    .CountAsync();
```

> Add a comment that this excludes walk-ins. Walk-in counting is out of scope for the v1 fix.

---

### 2.5 Add `DistanceKm` to `DoctorListItemDto`

**Why:** When the user is browsing doctors with a known location, the list should sort by distance and show "1.2 km". This is a tiny optional change.

**File:** `DTOs/Doctor/DoctorDtos.cs` — add to `DoctorListItemDto`:

```csharp
public double? DistanceKm { get; set; }
```

**File:** `Services/Implementations/DoctorService.cs` — in `GetAllDoctorsAsync` (line 106) and `GetPopularDoctorsAsync` (line 153):

- Accept an optional `double? userLat, double? userLng` parameter (or only populate when provided).
- If provided, compute `GeoUtils.HaversineKm` and set `dto.DistanceKm`.
- If null, leave it null (the existing controllers don't pass these, so existing behavior is preserved).

> The endpoint contract change is **additive** (new optional query params). Update the controllers in `DoctorController.cs` to accept the new params and pass them through.

```csharp
// In DoctorController.GetAll
[FromQuery] double? userLat = null,
[FromQuery] double? userLng = null

// Pass to service: GetAllDoctorsAsync(..., userLat, userLng)
```

Flutter call example: `GET /api/doctor?userLat=30.0444&userLng=31.2357`.

---

### 2.6 Seed Sample Lat/Lng for Clinics in `DbSeeder`

**Why:** Without sample coordinates, the seeded clinics won't appear on the map during dev. The DbSeeder currently has **no** lat/lng (verified — no matches in grep).

**File:** `Data/DbSeeder.cs`

Add realistic Egyptian coordinates to each seeded clinic. Examples (Cairo / Giza):

| Clinic | Government | Lat | Lng |
|---|---|---|---|
| Cairo Medical Center | Cairo | 30.0444 | 31.2357 |
| Nile Hospital | Giza | 30.0131 | 31.2089 |
| Alexandria Clinic | Alexandria | 31.2001 | 29.9187 |
| Mansoura Specialized | Dakahlia | 31.0409 | 31.3785 |

For any new seeded clinics, add `Latitude = ..., Longitude = ...` to the `new Clinic { ... }` initializer.

> Alternatively: skip this and rely on the Edit Clinic Profile to fill them. But for dev/demo, seeded coordinates make the map usable immediately.

---

### 2.7 Structured Prescription (Optional — Defer Unless Required)

**Current state:** The existing `MedicalRecord.Prescription` field is a `string?` (max 1000 chars). The `MedicalRecordService.CreateRecordAsync` (line 33-38) serializes the structured `Medications` list to JSON and stores it in that text field. The mapper in `MedicalRecordService.MapToDto` (line 234-262) and `DoctorService.MapMedicalRecordToDto` (line 812-833) parses it back on read. So the **wire format is already structured** — the storage is just hacky.

**Recommendation:** **Don't change the schema for this PR.** The JSON-in-text approach works. The trade-off:

| Aspect | Current (JSON in text) | Proper table |
|---|---|---|
| Query meds by name | ❌ Can't | ✅ Can |
| Index | ❌ | ✅ |
| Update single med | ❌ Rewrite whole field | ✅ |
| Migration | None | New table + FK |
| Code complexity | Low | Medium-High |

**Only do this if the Flutter app needs to:**
- Search patients by medication.
- List "all patients currently on Drug X".
- Edit a single medication without rewriting the full prescription.

If yes, the spec would be:
- New entity `PrescribedMedication` with FK to `MedicalRecord`, columns: `Name`, `Category`, `Dosage`, `Duration`, `Timing`, `Notes`, `Order`.
- New entity `PrescriptionTiming` (enum or lookup: `Before`, `After`, `WithFood`, `Bedtime`).
- Drop `Prescription` and `TreatmentPlan` text columns (or keep them as denormalized cache).
- Update DTOs to return `List<PrescribedMedicationDto>` (already exists).
- Update `MedicalRecordService.CreateRecordAsync` to insert into the new table.

Mark this as **P2 / backlog**.

---

## 3. Data Model & Migration Notes

**No new entities are required** for items 2.1-2.6. They only add:
- 2 new controller endpoints (`/api/clinic/nearby`, `/api/doctor/nearby`)
- 2 new DTO classes (`NearbyClinicDto`, `NearbyDoctorDto`)
- 2-3 new properties on existing DTOs (`DoctorProfileDto.ClinicLatitude/Longitude`, `DoctorProfileDto.TotalPatients`, `DoctorListItemDto.DistanceKm`)
- 1 new helper class (`Helpers/GeoUtils.cs`)

**No `dotnet ef migrations add ...` is required.**

If you do decide to do item 2.7 (structured prescription), you will need a migration.

---

## 4. Implementation Order (Recommended)

1. **`GeoUtils.cs`** — 5 min, zero risk, prerequisite for 2.1/2.2/2.5.
2. **`/api/clinic/nearby` (2.1) + DbSeeder lat/lng (2.6)** — Together so the map has data to show.
3. **`/api/doctor/nearby` (2.2)** — Same Haversine pattern, but on the doctor service.
4. **DTO additions: `DoctorProfileDto.ClinicLatitude/Longitude` (2.3), `TotalPatients` (2.4), `DoctorListItemDto.DistanceKm` (2.5)** — All small, can ship together.
5. **Structured prescription (2.7)** — Defer. Only do if a real Flutter feature requires it.

Estimated total backend effort: **0.5 to 1.5 days**, dominated by the new endpoints. The DTO additions are 30 min each.

---

## 5. Test / Verify Checklist

Before merging, verify:

- [ ] `GET /api/clinic/nearby?lat=30.0444&lng=31.2357&radiusKm=5` returns seeded clinics within 5 km, ordered by distance.
- [ ] `GET /api/clinic/nearby?lat=999&lng=999` (invalid coords) returns empty list, not 500.
- [ ] `GET /api/clinic/nearby` without lat/lng returns 400 (not 500).
- [ ] `GET /api/doctor/nearby?lat=30.0444&lng=31.2357&radiusKm=10&specialization=Cardiology` returns only cardio doctors within 10 km.
- [ ] `GET /api/doctor/{id}` response now includes `clinicLatitude` and `clinicLongitude`.
- [ ] `GET /api/doctor/{id}` response now includes `totalPatients` as a non-zero integer.
- [ ] `GET /api/doctor?userLat=30.04&userLng=31.23` sorts results by `distanceKm` (when set).
- [ ] Existing `GET /api/clinic?search=X` still works (regression check).
- [ ] `dotnet build` clean, no new warnings.
- [ ] Existing unit tests / smoke tests pass (note: this codebase doesn't have unit tests in `medicare-backend` — see note below).

> **Note on tests:** `medicare-backend` has no test project. Verification is done via Swagger UI in dev. If you want to add tests for the new endpoints, a `xUnit` project with a couple of in-memory-DB tests for Haversine would be the right shape.

---

## 6. Out of Scope (Explicitly Deferred)

- **AI Chatbot** — Requires an LLM integration decision (third-party API, self-hosted, or rule-based). No backend spec can be written without that decision.
- **Social Login (Google / Apple / Facebook)** — Requires OAuth app registration with each provider and a token verification flow. Per the user's instruction, deferred.
- **Telegram bot deep-linking** — Could be a nice UX add to the Telegram registration flow, but is a Flutter/bot-config concern, not backend.

---

## 7. Open Questions for the Team

1. **Radius default:** Is 5 km a reasonable default for the Nearby map, or should it be 2 km (urban) / 10 km (suburban)? Defer to UX.
2. **Doctor location priority:** When a doctor has multiple clinics, which one should be the "primary" for the map pin? Currently the first active in `DoctorClinics`. If clinics have different cities, the answer matters more.
3. **Walk-in patient counting:** Should `TotalPatients` count walk-ins (via phone) or only registered patients? Current spec excludes walk-ins for safety.
4. **Should nearby search require auth?** Current spec says no (public). If you want to gate it behind login, add `[Authorize]`. Trade-off: logged-out users can browse clinics but not doctors.

---

*End of Spec — Apply when ready; not live in the running backend.*
