# Graduation Project — Medicare

---

## Slide 1 — Architecture & Tech Stack

**Medicare — Flutter Cross-Platform Healthcare App**

---

**Architecture at a Glance**

- **State Management**: BLoC (flutter_bloc) — single AuthBloc drives auth, screens use direct service calls
- **Routing**: go_router — 50+ routes, 3 role-based bottom nav shells, auth guard redirect
- **Networking**: Dio singleton — JWT auto-inject, seamless 401 → refresh → retry
- **Storage**: flutter_secure_storage (tokens) + shared_preferences
- **Design**: Material 3 — blue (#2563EB) palette, Inter font
- **7 services** behind 3 role modules (Patient 21 screens, Doctor 12, Clinic 13)
- **6 platforms**: Android · iOS · Web · Windows · macOS · Linux

>

**Key Packages**

flutter_bloc · go_router · dio · flutter_map + geolocator · table_calendar · qr_flutter + mobile_scanner · cached_network_image + shimmer · google_fonts

---

## Slide 2 — Features

**One App, Three Roles**

---

**Patient** — *Discover → Book → Track → Review*
Browse/search doctors · GPS nearby map · Calendar + slot booking · Live queue tracker · Family member management · Medical history · Community feed · Favorites · Reviews

**Doctor** — *Dashboard → Queue → Consult → Document*
Today's stats · Live queue call-next · Full consultation workspace (history + diagnosis + Rx) · Schedule management · QR code check-in

**Clinic** — *Manage → Monitor → Register → Report*
Doctor directory (add via QR scan) · Per-doctor queue · Walk-in booking (even offline patients) · Schedule management · Payments dashboard (cash/online/refunds)

---

**Backend**: ASP.NET Core (.NET 8) + SQL Server — RESTful JSON at `medicare.shortformfunnels.com`

---
