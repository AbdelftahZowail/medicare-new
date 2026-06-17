when starting subagents or explorers, do NOT do their job for them, wait when it finishes or do something unrelated in the mean time instead

---

for debugging use the following tools:
the backend is running on a vps (the C:\Users\Zowail\StudioProjects\medicare\medicare-backend/ locally is just a git clone for you to view or edit for it to be synced with the version on the vps) in ~/medicare-backend with a systemd service and you can view the logs, to login use `ssh -i C:\Users\Zowail\.ssh\openclaw_proxy ubuntu@140.238.97.203` 

**do NOT deplot until the user verbally tells you to, then you will push changes to git, pull it on the other side, and deploy changes**

to login to testing accounts use these credentials:
patient: phonenumber 01067179861, password: password
doctor: phonenumber 01067179860, password: password
clinic: phonenumber 01067179862, password: password

---

anything endpoints related consult @medicare-backend/API_DOCUMENTATION.md first to be sure your calls are accurate and as expected