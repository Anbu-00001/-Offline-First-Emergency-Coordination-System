# SPDX-License-Identifier: GPL-3.0-or-later
"""Initial schema — incidents, responders, reports with PostGIS and sync metadata.

Revision ID: 0001
Revises: None
Create Date: 2026-03-01
"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
import geoalchemy2
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "0001"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Enable PostGIS extension
    op.execute("CREATE EXTENSION IF NOT EXISTS postgis")

    # --- incidents ---------------------------------------------------------
    op.create_table(
        "incidents",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        # Sync metadata
        sa.Column("client_id", postgresql.UUID(as_uuid=True), nullable=False, index=True,
                  comment="UUID of the originating offline client / node"),
        sa.Column("sequence_num", sa.BigInteger(), nullable=False, default=0, index=True,
                  comment="Lamport-style logical clock for conflict ordering"),
        sa.Column("deleted_flag", sa.Boolean(), nullable=False, default=False, index=True,
                  comment="Tombstone flag for soft-delete reconciliation"),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        # CAP fields
        sa.Column("identifier", sa.String(255), unique=True, nullable=False, index=True,
                  comment="CAP <identifier> — globally unique alert ID"),
        sa.Column("sender", sa.String(255), nullable=False,
                  comment="CAP <sender> — originating authority / node"),
        sa.Column("sent_at", sa.DateTime(timezone=True), nullable=False,
                  comment="CAP <sent> — timestamp of alert issuance"),
        sa.Column("status", sa.Enum("Pending", "Assigned", "Resolved",
                  name="incident_status", create_constraint=True),
                  nullable=False, index=True),
        sa.Column("msg_type", sa.Enum("Alert", "Update", "Cancel", "Ack", "Error",
                  name="cap_msg_type", create_constraint=True),
                  nullable=False),
        sa.Column("scope", sa.Enum("Public", "Restricted", "Private",
                  name="cap_scope", create_constraint=True),
                  nullable=False),
        sa.Column("category", sa.Enum("Geo", "Met", "Safety", "Security", "Rescue",
                  "Fire", "Health", "Env", "Transport", "Infra", "CBRNE", "Other",
                  name="cap_category", create_constraint=True),
                  nullable=False),
        sa.Column("headline", sa.String(512), nullable=True),
        sa.Column("description", sa.Text(), nullable=True),
        # PostGIS columns
        sa.Column("location", geoalchemy2.Geometry(
            geometry_type="POINT", srid=4326, from_text="ST_GeomFromEWKT",
            name="geometry"), nullable=True, index=True),
        sa.Column("avoidance_zone", geoalchemy2.Geometry(
            geometry_type="POLYGON", srid=4326, from_text="ST_GeomFromEWKT",
            name="geometry"), nullable=True),
    )

    # --- responders --------------------------------------------------------
    op.create_table(
        "responders",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        # Sync metadata
        sa.Column("client_id", postgresql.UUID(as_uuid=True), nullable=False, index=True),
        sa.Column("sequence_num", sa.BigInteger(), nullable=False, default=0, index=True),
        sa.Column("deleted_flag", sa.Boolean(), nullable=False, default=False, index=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        # Zero-Trust identity
        sa.Column("peer_id", sa.String(64), unique=True, nullable=False, index=True,
                  comment="SHA-256 hash of responder public key"),
        sa.Column("public_key", sa.Text(), nullable=True),
        # Profile
        sa.Column("callsign", sa.String(128), nullable=True),
        sa.Column("status", sa.Enum("Available", "Dispatched", "Offline",
                  name="responder_status", create_constraint=True),
                  nullable=False, index=True),
        sa.Column("is_verified", sa.Boolean(), nullable=False, default=False),
        # PostGIS
        sa.Column("last_known_location", geoalchemy2.Geometry(
            geometry_type="POINT", srid=4326, from_text="ST_GeomFromEWKT",
            name="geometry"), nullable=True, index=True),
    )

    # --- reports -----------------------------------------------------------
    op.create_table(
        "reports",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        # Sync metadata
        sa.Column("client_id", postgresql.UUID(as_uuid=True), nullable=False, index=True),
        sa.Column("sequence_num", sa.BigInteger(), nullable=False, default=0, index=True),
        sa.Column("deleted_flag", sa.Boolean(), nullable=False, default=False, index=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        # Foreign keys
        sa.Column("incident_id", postgresql.UUID(as_uuid=True),
                  sa.ForeignKey("incidents.id"), nullable=False, index=True),
        sa.Column("responder_id", postgresql.UUID(as_uuid=True),
                  sa.ForeignKey("responders.id"), nullable=False, index=True),
        # Content
        sa.Column("title", sa.String(512), nullable=False),
        sa.Column("body", sa.Text(), nullable=True),
        # PostGIS
        sa.Column("location", geoalchemy2.Geometry(
            geometry_type="POINT", srid=4326, from_text="ST_GeomFromEWKT",
            name="geometry"), nullable=True, index=True),
    )


def downgrade() -> None:
    op.drop_table("reports")
    op.drop_table("responders")
    op.drop_table("incidents")

    # Clean up enums
    sa.Enum(name="incident_status").drop(op.get_bind(), checkfirst=True)
    sa.Enum(name="cap_msg_type").drop(op.get_bind(), checkfirst=True)
    sa.Enum(name="cap_scope").drop(op.get_bind(), checkfirst=True)
    sa.Enum(name="cap_category").drop(op.get_bind(), checkfirst=True)
    sa.Enum(name="responder_status").drop(op.get_bind(), checkfirst=True)
