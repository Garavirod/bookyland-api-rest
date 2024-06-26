from fastapi import FastAPI
from database.db import create_db_connection
from api import books, genres, authors

app = FastAPI()

# Include router from endpoints
app.include_router(books.router)
app.include_router(genres.router)
app.include_router(authors.router)


