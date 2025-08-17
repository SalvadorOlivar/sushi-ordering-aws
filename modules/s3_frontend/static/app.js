// Cambia esta URL por la de tu API Gateway
const API_URL = 'https://j1qupm5h22.execute-api.us-east-1.amazonaws.com/test/v1/menu';

function fetchMenu() {
  fetch(API_URL)
    .then(res => res.json())
    .then(data => {
      const list = document.getElementById('menu-list');
      list.innerHTML = '';
      data.forEach(item => {
        const div = document.createElement('div');
        div.className = 'menu-item';
        div.innerHTML = `<span>${item.nombre_plato}</span> <button onclick="deleteMenu('${item.id}')">Eliminar</button>`;
        list.appendChild(div);
      });
    });
}

function deleteMenu(id) {
  fetch(API_URL, {
    method: 'DELETE',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ id: id })
  }).then(() => fetchMenu());
}

document.getElementById('add-form').addEventListener('submit', function(e) {
  e.preventDefault();
  const data = {
    nombre_plato: document.getElementById('nombre_plato').value,
    precio: parseFloat(document.getElementById('precio').value),
    descripcion: document.getElementById('descripcion').value,
    disponible: document.getElementById('disponible').checked
  };
  fetch(API_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(data)
  }).then(() => {
    fetchMenu();
    document.getElementById('add-form').reset();
  });
});

fetchMenu();
