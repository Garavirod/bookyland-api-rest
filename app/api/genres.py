from pydantic import BaseModel
from fastapi import Depends
from models.books import Genre
from fastapi import APIRouter
from database.db import create_db_connection
from sqlalchemy.orm import Session


router = APIRouter(prefix='/genres')


class GenreCreate(BaseModel):
    name: str


@router.post('/create-genre/', response_model=GenreCreate)
async def create_book(item: GenreCreate, db: Session = Depends(create_db_connection)):
    new_item = Genre(name=item.name)
    db.add(new_item)
    db.commit()
    db.refresh(new_item)
    return new_item

