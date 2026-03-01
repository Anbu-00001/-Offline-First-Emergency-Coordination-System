# SPDX-License-Identifier: GPL-3.0-or-later
"""
Report model — field observations submitted by responders.

Each report is geotagged and linked to both an incident and a responder
(via their cryptographic peer_id).
"""
import uuid

from sqlalchemy import (
    Column,
    String,
    Text,
    ForeignKey,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from geoalchemy2 import Geometry

from .base import Base, SyncMixin


class Report(SyncMixin, Base):
    """
    A field report linked to an incident and a responder.
    """
    __tablename__ = "reports"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
    )

    # --- Foreign keys ------------------------------------------------------
    incident_id = Column(
        UUID(as_uuid=True),
        ForeignKey("incidents.id"),
        nullable=False,
        index=True,
    )
    responder_id = Column(
        UUID(as_uuid=True),
        ForeignKey("responders.id"),
        nullable=False,
        index=True,
    )

    # --- Content -----------------------------------------------------------
    title = Column(String(512), nullable=False, comment="Brief report title")
    body = Column(Text, nullable=True, comment="Detailed observation text")

    # --- PostGIS geospatial ------------------------------------------------
    location = Column(
        Geometry(geometry_type="POINT", srid=4326),
        nullable=True,
        index=True,
        comment="Where the observation was made — WGS 84 POINT",
    )

    # --- ORM relationships -------------------------------------------------
    incident = relationship("Incident", backref="reports", lazy="selectin")
    responder = relationship("Responder", backref="reports", lazy="selectin")

    def __repr__(self) -> str:
        return f"<Report id={self.id} incident={self.incident_id}>"
