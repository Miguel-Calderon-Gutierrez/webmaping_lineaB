from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List
import asyncpg

class Geometry(BaseModel):
    type: str = Field(..., example="Point")
    coordinates: List[float] = Field(..., example=[-58.381559, -34.603684])

class Visita(BaseModel):
    cedula: str = Field(..., example="45678")
    nombreVisitante: str = Field(..., example="Miguel Calderon")
    nombreDrogueria: str = Field(..., example="farmaciaX")
    geometry: Geometry

app = FastAPI()

# Configuración de CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Permite todas las fuentes
    allow_credentials=True,
    allow_methods=["*"],  # Permite todos los métodos
    allow_headers=["*"],  # Permite todos los encabezados
)

@app.post("/marcarVisita")
async def marcar_visita(visita: Visita):
    conn = None
    try:
        # Conexión a la base de datos
        conn = await asyncpg.connect('postgresql://postgres:1234@localhost/proyectofinal')
        # Llamada al procedimiento almacenado
        await conn.execute('''
            SELECT registrar_visita($1, $2, $3, $4, $5)
        ''', visita.cedula, visita.nombreVisitante, visita.nombreDrogueria, visita.geometry.type, visita.geometry.coordinates)
        return {"message": f"Visita marcada para {visita.nombreVisitante} con la cédula {visita.cedula}"}
    except Exception as e:
        print("Error al registrar la visita:", str(e))
        raise HTTPException(status_code=500, detail=f"Internal Server Error: {str(e)}")
    finally:
        if conn:
            await conn.close()


