# SPDX-License-Identifier: GPL-3.0-or-later
"""
Base model and SyncMixin for Offline-First Synchronization.

Every table inherits the SyncMixin, which provides the three mandatory
columns for distributed state reconciliation:
  - client_id:    UUID identifying the originating offline node.
  - sequence_num: BigInt logical clock for conflict-free ordering.
  - deleted_flag: Soft-delete marker (tombstone) for CRDT-style sync.
"""
import uuid
from datetime import datetime, timezone

from sqlalchemy import (
    Column,
    DateTime,
    Boolean,
    BigInteger,
)
from sqlalchemy.dialects.postgresql import UUID

from ..core.database import Base


class SyncMixin:
    """Mixin injected into every domain table for offline-first sync."""

    client_id = Column(
        UUID(as_uuid=True),
        nullable=False,
        default=uuid.uuid4,
        index=True,
        comment="UUID of the originating offline client / node",
    )
    sequence_num = Column(
        BigInteger,
        nullable=False,
        default=0,
        index=True,
        comment="Lamport-style logical clock for conflict ordering",
    )
    deleted_flag = Column(
        Boolean,
        nullable=False,
        default=False,
        index=True,
        comment="Tombstone flag for soft-delete reconciliation",
    )

    # Audit timestamps
    created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
    )
    updated_at = Column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )
