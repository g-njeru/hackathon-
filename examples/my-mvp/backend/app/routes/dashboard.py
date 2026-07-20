from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.database import get_db
from app.models import Document, User
from app.auth import get_current_user

router = APIRouter(tags=["dashboard"])


@router.get("/dashboard/stats")
async def get_stats(
    user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    # Total documents
    total_result = await db.execute(
        select(func.count(Document.id)).where(Document.user_id == user.id)
    )
    total = total_result.scalar() or 0

    # Documents with content (not empty)
    with_content_result = await db.execute(
        select(func.count(Document.id)).where(
            Document.user_id == user.id,
            Document.content != "",
            Document.content.isnot(None),
        )
    )
    with_content = with_content_result.scalar() or 0

    # Recent documents (last 5)
    recent_result = await db.execute(
        select(Document)
        .where(Document.user_id == user.id)
        .order_by(Document.created_at.desc())
        .limit(5)
    )
    recent = [
        {"id": d.id, "title": d.title, "created_at": d.created_at.isoformat()}
        for d in recent_result.scalars().all()
    ]

    # Longest document
    longest_result = await db.execute(
        select(Document)
        .where(Document.user_id == user.id)
        .order_by(func.length(Document.content).desc())
        .limit(1)
    )
    longest = longest_result.scalar_one_or_none()
    longest_info = None
    if longest:
        longest_info = {
            "id": longest.id,
            "title": longest.title,
            "content_length": len(longest.content or ""),
        }

    return {
        "total_documents": total,
        "with_content": with_content,
        "empty": total - with_content,
        "recent": recent,
        "longest": longest_info,
    }
