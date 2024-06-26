from sqlalchemy import create_engine
from environment import DATABASE_USER, DATABASE_PORT, DATABASE_HOST, DATABASE_NAME, DATABASE_PASSWORD
from sqlalchemy.orm import sessionmaker


def create_db_connection():
    # Database connection details (replace with your own)
    DATABASE_URL = F"mysql+mysqlconnector://{DATABASE_USER}:{DATABASE_PASSWORD}@mysql:{DATABASE_PORT}/{DATABASE_NAME}"
    engine = create_engine(DATABASE_URL)
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    db_connection = SessionLocal()
    try:
        yield db_connection
    finally:
        db_connection.close()
