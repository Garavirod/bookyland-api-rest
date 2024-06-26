from pydantic import BaseModel
from fastapi import Depends
from models.books import Author
from fastapi import APIRouter
from database.db import create_db_connection

router = APIRouter(prefix='/authors')


class AuthorRequest(BaseModel):
    name: str
    last_name: str


@router.post('/create-author/')
async def create_author(item: AuthorRequest, db=Depends(create_db_connection)):
    new_item = Author(name=item.name, last_name=item.last_name)
    db.add(new_item)
    db.commit()
    return new_item
