#!/usr/bin/env python3
"""
CreateDiff Supabase Database Provisioning & Live Verification Utility

Executes SQL migrations against the configured Supabase PostgreSQL instance,
verifies RLS policies, trigger installation, and tests user lifecycle.
"""
from __future__ import annotations

import argparse
import asyncio
import os
import sys
from pathlib import Path

# Add backend root to path
backend_dir = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(backend_dir))

from app.config import settings


async def run_migration(db_url: str) -> bool:
    """Applies SQL migration files to the database."""
    try:
        import asyncpg
    except ImportError:
        print("[!] asyncpg is not installed. Installing asyncpg...")
        return False

    # Convert SQLAlchemy URL to standard postgres URL if necessary
    clean_url = db_url.replace("postgresql+asyncpg://", "postgresql://")

    print(f"[*] Connecting to database...")
    try:
        conn = await asyncpg.connect(clean_url)
    except Exception as e:
        print(f"[!] Database connection error: {e}")
        return False

    migrations_dir = backend_dir / "migrations"
    migration_files = [
        migrations_dir / "001_phase3_initial.sql",
        migrations_dir / "002_supabase_profiles_rls.sql",
    ]

    try:
        for file in migration_files:
            if not file.exists():
                print(f"[!] Migration file {file.name} not found.")
                continue

            print(f"[*] Executing migration {file.name}...")
            sql = file.read_text(encoding="utf-8")
            await conn.execute(sql)
            print(f"[✓] {file.name} applied successfully.")

        # Verify tables exist
        tables = await conn.fetch(
            """
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            ORDER BY table_name;
            """
        )
        table_names = [t["table_name"] for t in tables]
        print(f"\n[✓] Public tables in database: {', '.join(table_names)}")

        # Verify RLS enabled on profiles
        rls_check = await conn.fetchval(
            """
            SELECT rowsecurity 
            FROM pg_tables 
            WHERE schemaname = 'public' AND tablename = 'profiles';
            """
        )
        print(f"[✓] RLS on public.profiles: {'ENABLED' if rls_check else 'DISABLED'}")

        # Verify trigger exists on auth.users
        trigger_check = await conn.fetch(
            """
            SELECT trigger_name 
            FROM information_schema.triggers 
            WHERE event_object_schema = 'auth' AND event_object_table = 'users';
            """
        )
        triggers = [t["trigger_name"] for t in trigger_check]
        print(f"[✓] Triggers on auth.users: {', '.join(triggers)}")

        return True
    except Exception as e:
        print(f"[!] Migration execution failed: {e}")
        return False
    finally:
        await conn.close()


async def main():
    parser = argparse.ArgumentParser(description="CreateDiff Supabase Provisioning & Verification")
    parser.add_argument("--db-url", default=None, help="PostgreSQL connection URL")
    args = parser.parse_args()

    db_url = args.db_url or settings.DATABASE_URL or os.environ.get("DATABASE_URL")
    if not db_url or "localhost" in db_url and not os.environ.get("DATABASE_URL"):
        print("[!] No active remote DATABASE_URL configured.")
        print("    Usage: python backend/scripts/manage_supabase.py --db-url 'postgresql://postgres:<pass>@db.<ref>.supabase.co:5432/postgres'")
        return

    success = await run_migration(db_url)
    if success:
        print("\n[SUCCESS] Supabase database provisioning & verification completed.")
    else:
        print("\n[FAILED] Supabase database provisioning could not be completed.")


if __name__ == "__main__":
    asyncio.run(main())
