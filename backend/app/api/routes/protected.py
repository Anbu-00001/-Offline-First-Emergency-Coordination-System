from fastapi import APIRouter, Depends
from app.models.user import User
from app.schemas.user import UserOut
from app.core.security import get_current_user

router = APIRouter()

@router.get("/protected", response_model=UserOut)
def read_protected(current_user: User = Depends(get_current_user)):
    """
    Protected route example. Requires a valid JWT to access.
    Returns the currently authenticated user's information.
    """
    return current_user
