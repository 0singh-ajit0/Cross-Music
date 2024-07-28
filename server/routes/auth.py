import uuid
import bcrypt
from fastapi import Depends, HTTPException, APIRouter
from sqlalchemy.orm import Session, joinedload
import jwt

from database import get_db
from middleware.auth_middleware import auth_middleware
from models.user import User
from pydantic_schemas.user_create import UserCreate
from pydantic_schemas.user_login import UserLogin

router = APIRouter()


@router.post("/signup", status_code=201)
def signup_user(user: UserCreate, db: Session = Depends(get_db)):
    user_db = db.query(User).filter(User.email == user.email).first()

    if user_db:
        raise HTTPException(
            status_code=400, detail="User with the same email already exists"
        )

    hashed_pw = bcrypt.hashpw(user.password.encode(), bcrypt.gensalt(16))
    new_user = User(
        id=str(uuid.uuid4()), name=user.name, email=user.email, password=hashed_pw
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return new_user


@router.post("/login")
def login_user(user: UserLogin, db: Session = Depends(get_db)):
    user_db = db.query(User).filter(User.email == user.email).first()

    if not user_db:
        raise HTTPException(
            status_code=400, detail="User with this email doesn't exists"
        )

    isMatched = bcrypt.checkpw(
        password=user.password.encode(),
        hashed_password=user_db.password,  # type: ignore
    )
    if not isMatched:
        raise HTTPException(status_code=400, detail="Incorrect password!")

    token = jwt.encode(payload={"id": user_db.id}, key="password_key")

    return {"token": token, "user": user_db}


@router.get("/")
def getUserData(db: Session = Depends(get_db), user_dict=Depends(auth_middleware)):
    user = (
        db.query(User)
        .filter(User.id == user_dict["uid"])
        .options(joinedload(User.favorites))
        .first()
    )
    if not user:
        raise HTTPException(404, "User not found!")
    return user
