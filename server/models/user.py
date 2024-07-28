from models.base import Base
from sqlalchemy import Column
from sqlalchemy.sql import sqltypes
from sqlalchemy.orm import relationship


class User(Base):
    __tablename__ = "users"

    id = Column(sqltypes.TEXT, primary_key=True)
    name = Column(sqltypes.VARCHAR(100))
    email = Column(sqltypes.VARCHAR(100))
    password = Column(sqltypes.LargeBinary)

    favorites = relationship("Favorite", back_populates="user")
