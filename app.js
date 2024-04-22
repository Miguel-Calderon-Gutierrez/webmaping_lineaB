var drogueriasflorencia, farmacias, osm, osmHOT;
var baseMaps, overlayMaps;

// Define un icono personalizado para las droguerías
const drogueriaIcon = L.icon({
  iconUrl: "/icono.png",
  iconSize: [24, 24],
  iconAnchor: [24, 24],
  popupAnchor: [0, -16],
});

//Configuración capa base de OpenStreetMap
function InitialConfig() {
  osm = L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
    attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a>',
  });

  osmHOT = L.tileLayer(
    "https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png",
    {
      attribution: "© OpenStreetMap",
    }
  );
}

// Capa WMS droguerias de Florencia de GeoServer
function getPointsDroguerias() {
  drogueriasflorencia = L.tileLayer.wms(
    "http://localhost:8080/geoserver/LineaB/wms",
    {
      layers: "LineaB:drogueriasflorencia",
      format: "image/png",
      transparent: true,

      pointToLayer: function (feature, latlng) {
        return L.marker(latlng, { icon: drogueriaIcon });
      },
    }
  );

  //getDataDroguerias();
}


function getDataDroguerias() {
  const url =
    "http://localhost:8080/geoserver/LineaB/wfs?service=WFS&version=1.1.0&request=GetFeature&typeName=LineaB%3Adrogueriasflorencia&outputFormat=application%2Fjson";

  farmacias = L.layerGroup(); // Inicializa la layerGroup aquí

  fetch(url)
    .then((response) => {
      if (!response.ok) {
        throw new Error("Error al realizar la solicitud");
      }
      return response.json();
    })
    .then((data) => {
      data.features.forEach((drogueria) => {
        const latlng = [
          drogueria.geometry.coordinates[1],
          drogueria.geometry.coordinates[0],
        ];
        const marker = L.marker(latlng, { icon: drogueriaIcon });

        const nombre = drogueria.properties.name;
        const idDrogueria = drogueria.properties.id;
        const direccion = drogueria.properties.adress;
        const numero = drogueria.properties.number;
        //const horario = drogueria.properties.hoursatent;  <b id="infoDrogeria"> <strong>horario: </strong>   ${horario} </b>

        const popupContent = `
                              <div>
                                <b id="infoDrogeria"> <strong>Nombre: </strong>   ${idDrogueria} - ${nombre}</b>  
                                <br/>
                                <b id="infoDrogeria"> <strong>direccion: </strong>   ${direccion} </b>  
                                <br/>
                                <b id="infoDrogeria"> <strong>numero: </strong>   ${numero} </b>  
                                <br/>
                              
                              </div>
                              <img id="fotoDrogueria" src="${drogueria.properties.photo}"> 
                              <br/>
                              <button id="btn-${idDrogueria}" class="btn btn-secondary botonDrogueria">Marcar visita</button>
                              `;

        marker.bindPopup(popupContent);

        marker.on("popupopen", () => {
          document
            .querySelector(`#btn-${idDrogueria}`)
            .addEventListener("click", () => {
              registrarVisita(drogueria.geometry, nombre);
            });
        });

        farmacias.addLayer(marker); // Añade cada marcador directamente a la layerGroup
      });
      farmacias.addTo(map); // Añade la capa de marcadores al mapa aquí

      // Initialize search control here after data is loaded
      var searchControl = new L.Control.Search({
        layer: farmacias,
        propertyName: 'name',
        autoCollapse: true,
        autoType: false,
        minLength: 3
      });

      searchControl.addTo(map);

    })
    .catch((error) => {
      console.error("Error:", error);
    });
}

//formulario para registrar la visita
function registrarVisita(geometry, nombreDrogueria) {
  Swal.fire({
    title: "REGISTRO DE VISITA",
    html: `
      <h2>Nombre:</h2>
      <input type="text" id="nombre" class="swal2-input" placeholder="Nombre">
      <h2>Cedula:</h2>
      <input type="number" id="cc" class="swal2-input" placeholder="123456">`,
    focusConfirm: false,
    preConfirm: () => {
      const nombre = Swal.getPopup().querySelector("#nombre").value;
      const cedula = Swal.getPopup().querySelector("#cc").value;
      if (!nombre || !cedula) {
        Swal.showValidationMessage("Por favor completa ambos campos");
        return false;
      }
      return {
        cedula: cedula,
        nombreVisitante: nombre,
        nombreDrogueria: nombreDrogueria,
        geometry: geometry,
      };
    },
    customClass: {
      confirmButton: "btn btn-primary", // Aplicando clase de botón de Bootstrap
      cancelButton: "btn btn-default",
    },
    buttonsStyling: false,
  }).then((result) => {
    if (result.isConfirmed) {
      enviarDatos(result.value);
    }
  });
}
// Función para enviar datos a la DB mediabte la API
function enviarDatos(datos) {
  console.table(datos); // Muestra los datos en la consola en formato tabla.

  fetch("http://localhost:8000/marcarVisita", {
    // Asegúrate de incluir el puerto correcto si es necesario.
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(datos),
  })
    .then((response) => {
      if (!response.ok) {
        // Verifica si la respuesta del servidor es exitosa.
        throw new Error("Respuesta de red no fue ok.");
      }
      return response.json(); // Convierte la respuesta en JSON.
    })
    .then((data) => {
      Swal.fire({
        // SweetAlert para mostrar un mensaje de éxito.
        title: "¡Éxito!",
        text: "Visita registrada",
        icon: "success",
      });
    
      fetchVisits();
    
    })
    .catch((error) => {
      console.error("Error al registrar la visita:", error);
      Swal.fire({
        // SweetAlert para mostrar un mensaje de error.
        title: "Error",
        text: "Ups, no se pudo registrar la visita",
        icon: "error",
      });
    });
}
//Se pide permiso y se obtine la ubicación del cliente
function ubicacionCliente() {
  if ("geolocation" in navigator) {
    navigator.geolocation.getCurrentPosition(
      (position) => {
        const { latitude, longitude } = position.coords;
        const iconoUsuario = L.icon({
          iconUrl: "/persona.png",
          iconSize: [32, 32],
          iconAnchor: [16, 32],
          popupAnchor: [0, -32],
        });
        L.marker([latitude, longitude], { icon: iconoUsuario })
          .addTo(map)
          .bindPopup("Tú estás aquí")
          .openPopup();
        map.setView([latitude, longitude], 14);
      },
      (error) => {
        Swal.fire({
          title: "Error",
          text: "No se pudo acceder a la ubicacion :( ",
          icon: "error",
        });
      }
    );
  } else {
    console.error("La geolocalización no es compatible con este navegador.");
  }
}

async function fetchVisits() {
  try {
    const response = await fetch('http://localhost:8080/geoserver/LineaB/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=LineaB%3Acantidad_droguerias_distintas_visitadas&maxFeatures=50&outputFormat=application%2Fjson');
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    const data = await response.json();

    const features = data.features; // Asumiendo que los datos están encapsulados en 'features' para GeoServer WFS
    const tableBody = document.getElementById('tableVisits').getElementsByTagName('tbody')[0];
    tableBody.innerHTML = ''; // Limpiar el cuerpo de la tabla antes de añadir nuevos datos

    features.forEach((feature) => {
      const row = tableBody.insertRow();
      const cell1 = row.insertCell(0);
      const cell2 = row.insertCell(1);
      const cell3 = row.insertCell(2);
      const cell4 = row.insertCell(3); // Celda para el botón

      cell1.textContent = feature.properties.cedula;
      cell2.textContent = feature.properties.nombrevisitante;
      cell3.textContent = feature.properties.cantidad_droguerias_distintas_visitadas;

      const button = document.createElement('button');
      button.textContent = 'Ver Droguerías';
      button.className = 'btn btn-success';
      button.onclick = function() {
        window.location.href = `detalleVisitas.html?cedula=${feature.properties.cedula}`;
      };
      cell4.appendChild(button);
    });

  } catch (error) {
    console.error('Error fetching data: ', error);
  }
}


//pendiente--------------------------------
function agregarControlBusqueda() {}

var map;

function main() {
  InitialConfig();
  getPointsDroguerias();
  getDataDroguerias();
  ubicacionCliente();

  map = L.map("map", {
    center: [1.6144, -75.6117],
    zoom: 14,
    layers: [osm, osmHOT, farmacias],
  });

  var baseMaps = {
    OpenStreetMap: osm,
    "OpenStreetMap.HOT": osmHOT,
  };

  overlayMaps = {
    DrogueriasIconos: farmacias,
    DrogueriasPuntos: drogueriasflorencia,
  };

  let layerControl = L.control.layers(baseMaps, overlayMaps).addTo(map);


  fetchVisits()


}

main();
