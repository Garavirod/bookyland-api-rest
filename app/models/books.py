from pydantic import BaseModel
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String, ForeignKey, VARCHAR
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship


Base = declarative_base()


class Author(Base):
    __tablename__ = "authors"
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    name = Column(String(100))
    last_name = Column(String(100))


class Genre(Base):
    __tablename__ = "genres"
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    name = Column(String(100))


class Book(Base):
    __tablename__ = "books"
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    title = Column(String(100))
    isb = Column(String(100))
    author_id = Column(Integer, ForeignKey(
        'authors.id', ondelete='CASCADE', onupdate='CASCADE'))
    genre_id = Column(Integer, ForeignKey(
        'genres.id', ondelete='CASCADE', onupdate='CASCADE'))
    author = relationship("Author", backref='books')
    genre = relationship("Genre", backref="books")
