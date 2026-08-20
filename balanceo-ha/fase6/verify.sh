{
  "title": "Balanceo de carga y alta disponibilidad",
  "description": "Laboratorio práctico de infraestructura cloud con Docker, Nginx y HAProxy",
  "details": {
    "intro": {
      "text": "intro.md"
    },
    "steps": [
      {
        "title": "Fase 1 - Preparación del entorno",
        "text": "fase1.md",
        "verify": "fase1/verify.sh"
      },
      {
        "title": "Fase 2 - Creación de la red privada",
        "text": "fase2.md",
        "verify": "fase2/verify.sh"
      },
      {
        "title": "Fase 3 - Servidor WEB01",
        "text": "fase3.md",
        "verify": "fase3/verify.sh"
      },
      {
        "title": "Fase 4 - Servidor WEB02",
        "text": "fase4.md",
        "verify": "fase4/verify.sh"
      },
      {
        "title": "Fase 5 - Balanceador HAProxy",
        "text": "fase5.md",
        "verify": "fase5/verify.sh"
      },
      {
        "title": "Fase 6 - Monitoreo del balanceo",
        "text": "fase6.md",
        "verify": "fase6/verify.sh"
      },
      {
        "title": "Fase 7 - Resiliencia y alta disponibilidad",
        "text": "fase7.md",
        "verify": "fase7/verify.sh"
      },
      {
        "title": "Fase 8 - Recuperación, escalabilidad y cierre",
        "text": "fase8.md",
        "verify": "fase8/verify.sh"
      }
    ],
    "finish": {
      "text": "finish.md"
    }
  },
  "backend": {
    "imageid": "ubuntu"
  }
}
