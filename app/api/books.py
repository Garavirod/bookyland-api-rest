from pydantic import BaseModel
from fastapi import Depends
from models.books import Book
from fastapi import APIRouter
from database.db import create_db_connection
from sqlalchemy.orm import Session

router = APIRouter(prefix='/books')


class BookRequest(BaseModel):
    title: str
    isbn: str
    author_id: int
    genre_id: int


@router.post('/create-book/')
async def create_book(item: BookRequest, db: Session = Depends(create_db_connection)):
    new_book = Book(title=item.title, isbn=item.isbn,
                    author_id=item.author_id, genre_id=item.genre_id)
    db.add(new_book)
    db.commit()
    db.refresh(new_book)
    return new_book
