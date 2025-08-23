// Cambia esta URL por la de tu API Gateway
const API_URL = 'https://l6h6mdzou7.execute-api.us-east-1.amazonaws.com/test/v1/menu';

function fetchMenu() {
  fetch(API_URL)
    .then(res => res.json())
    .then(data => {
      const list = document.getElementById('menu-list');
      list.innerHTML = '';
      data.forEach(item => {
        const div = document.createElement('div');
        div.className = 'menu-item';
  div.innerHTML = `<span>${item.dish_name}</span> <button onclick="deleteMenu('${item.id}')">Delete</button>`;
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
  dish_name: document.getElementById('dish_name').value,
  price: parseFloat(document.getElementById('price').value),
  description: document.getElementById('description').value,
  available: document.getElementById('available').checked
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
