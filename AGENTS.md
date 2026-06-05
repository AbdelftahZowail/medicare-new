when starting subagents or explorers, do NOT do their job for them, wait when it finishes or do something unrelated in the mean time instead

---

Do NOT make backend changes directly. Instead, describe the problem clearly and suggest the solution conceptually without writing full code snippets. The user will handle the implementation.

---

for debugging use the following tools:
the backend is running on a vps (medicare-backend is just a clone that might be outdated too) in ~/medicare-backend with a systemd service adn you can view the logs, to login use `ssh -i C:\Users\Zowail\.ssh\openclaw_proxy ubuntu@140.238.97.203` 

to login to testing accounts use these credentials:
patient: phonenumber 01067179861, password: password
doctor: phonenumber 01067179860, password: password
clinic: phonenumber 01067179862, password: password