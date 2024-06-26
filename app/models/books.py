from pydantic import BaseModel
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship


Base = declarative_base()


class Author(Base):
    __tablename__ = "authors"
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    name = Column(String)
    last_name = Column(String)


class Genre(Base):
    __tablename__ = "genres"
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    name = Column(String)


class Book(Base):
    __tablename__ = "books"
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    title = Column(String)
    isb = Column(String)
    author_id = Column(Integer, ForeignKey(
        'authors.id', ondelete='CASCADE', onupdate='CASCADE'))
    genre_id = Column(Integer, ForeignKey(
        'genres.id', ondelete='CASCADE', onupdate='CASCADE'))
    author = relationship("Author", backref='books')
    genre = relationship("Genres", backref="books")
