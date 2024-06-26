from pydantic import BaseModel
from fastapi import Depends
from models.books import Genre
from fastapi import APIRouter
from database.db import create_db_connection
from sqlalchemy.orm import Session

router = APIRouter(prefix='/genres')


class GenreRequest(BaseModel):
    name: str


@router.post('/create-book/')
async def create_book(item: GenreRequest, db: Session = Depends(create_db_connection)):
    new_item = Genre(name=item.name)
    db.add(new_item)
    db.commit()
    return new_item
