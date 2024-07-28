import uuid
from fastapi import APIRouter, Depends, File, Form, UploadFile
from sqlalchemy.orm import Session, joinedload
from database import get_db
from middleware.auth_middleware import auth_middleware
import cloudinary
import cloudinary.uploader

from models.favorite import Favorite
from models.song import Song
from pydantic_schemas.favorite_song import FavoriteSong


router = APIRouter()

cloudinary.config(
    cloud_name="cloud_name",
    api_key="api_key",
    api_secret="api_secret",
    secret=True,
)


@router.get("/list")
def list_songs(
    db: Session = Depends(get_db),
    auth_details=Depends(auth_middleware),
):
    songs = db.query(Song).all()
    return songs


@router.post("/upload", status_code=201)
def upload_song(
    song: UploadFile = File(...),
    thumbnail: UploadFile = File(...),
    artist: str = Form(...),
    song_name: str = Form(...),
    color_hex_code: str = Form(...),
    db: Session = Depends(get_db),
    auth_details=Depends(auth_middleware),
):
    song_id = str(uuid.uuid4())
    song_res = cloudinary.uploader.upload(
        song.file,
        resource_type="auto",
        folder=f"songs/{song_id}",
    )

    thumbnail_res = cloudinary.uploader.upload(
        thumbnail.file,
        resource_type="image",
        folder=f"songs/{song_id}",
    )

    new_song = Song(
        id=song_id,
        song_name=song_name,
        artist=artist,
        color_hex_code=color_hex_code,
        song_url=song_res["url"],
        thumbnail_url=thumbnail_res["url"],
    )

    db.add(new_song)
    db.commit()
    db.refresh(new_song)

    return new_song


@router.post("/favorite")
def favorite_song(
    song: FavoriteSong,
    db: Session = Depends(get_db),
    auth_details=Depends(auth_middleware),
):
    # song is already favorited by user
    user_id = auth_details["uid"]
    fav_song_db = (
        db.query(Favorite)
        .filter(Favorite.song_id == song.song_id, Favorite.user_id == user_id)
        .first()
    )
    # if the song is favorited, unfavorite it
    if fav_song_db:
        db.delete(fav_song_db)
        db.commit()
        return {"message": False}
    # else favorite it
    else:
        new_fav = Favorite(id=str(uuid.uuid4()), song_id=song.song_id, user_id=user_id)
        db.add(new_fav)
        db.commit()
        return {"message": True}


@router.get("/list/favorites")
def list_fav_songs(
    db: Session = Depends(get_db),
    auth_details=Depends(auth_middleware),
):
    user_id = auth_details["uid"]
    fav_songs = (
        db.query(Favorite)
        .filter(Favorite.user_id == user_id)
        .options(
            joinedload(Favorite.song),
            joinedload(Favorite.user),
        )
        .all()
    )
    return fav_songs
