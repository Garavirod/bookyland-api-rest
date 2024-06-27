from sqlalchemy import create_engine
from environment import DATABASE_USER, DATABASE_PORT, DATABASE_HOST, DATABASE_NAME, DATABASE_PASSWORD
from sqlalchemy.orm import sessionmaker
from models.books import Base

def create_db_connection():
    # Database connection details
    DATABASE_URL = f"mysql+mysqlconnector://{DATABASE_USER}:{DATABASE_PASSWORD}@{DATABASE_HOST}:{DATABASE_PORT}/{DATABASE_NAME}"
    engine = create_engine(DATABASE_URL)
    Base.metadata.create_all(bind=engine)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    db_connection = SessionLocal()
    try:
        yield db_connection
    finally:
        db_connection.close()
