# Ansible automation for e-commerce-system

This directory contains a simple Ansible configuration that installs the Java/Maven/ PostgreSQL stack, deploys the application code and configures systemd service units.

## Structure

```
ansible/
├── ansible.cfg                # defaults (inventory, connection settings)
└── production/
    └── company/
        ├── inventory.ini      # hosts to target
        ├── playbook.yml       # entry point
        └── roles/
            ├── database/      # installs postgres and runs schema
            │   ├── tasks/main.yml
            │   └── handlers/main.yml
            └── application/   # copies project, builds, installs services
                └── tasks/main.yml
```

## Quickstart

1. Copy this entire `ansible` directory to your orchestration server (e.g. the machine from which you run `ansible-playbook`).
2. Edit `production/company/inventory.ini` and list your EC2 instances under the `[ecommerce]` group. Use `ansible_user=ec2-user` or rely on `ansible.cfg` default.
3. Ensure that the SSH private key used to access the hosts is available on the orchestrator and referenced in `ansible.cfg` (or pass `-u`/`-i` CLI options).
4. From the orchestrator, run:

   ```bash
   cd <path-to>/ansible
   ansible-playbook production/company/playbook.yml
   ```

   Tags can be specified (`--tags packages`, `--tags database`) to limit tasks.

## How this solves your original problems

* The `database` role creates a PostgreSQL role named `ec2_user` (and an alias `ec2-user`).  Once the role exists you can run SQL from the EC2 user without copying the project to `/tmp`:
  ```bash
  psql -U ec2_user -d ecommerce -f /home/ec2-user/e-commerce-system/setup-postgresql.sql
  ```
  Alternatively the playbook itself runs the script as `postgres` and sets correct permissions on the project directory.
* `pg_hba.conf` is automatically adjusted to use `md5` authentication.
* Packages are installed, the database initialized, and services started for you.

## Notes

* The sample password in `playbook.yml` is insecure – use Ansible Vault or environment variables in production.
* The `synchronize` task assumes the control machine has the repository checked out. Adjust accordingly if pulling from SCM.
* Adjust Java/Maven package names to match the version you require.

---
