const API_MENU_URL = 'https://l6h6mdzou7.execute-api.us-east-1.amazonaws.com/test/v1/menu';

function fetchOwnerMenu() {
  fetch(API_MENU_URL)
    .then(res => res.json())
    .then(data => {
      const list = document.getElementById('owner-menu-list');
      list.innerHTML = '';
      data.forEach(item => {
        const col = document.createElement('div');
        col.className = 'col-md-4 d-flex';
        const card = document.createElement('div');
        card.className = 'card h-100 shadow-sm w-100';
        const cardBody = document.createElement('div');
        cardBody.className = 'card-body';
        const title = document.createElement('h5');
        title.className = 'card-title';
        title.textContent = item.dish_name;
        cardBody.appendChild(title);
        const price = document.createElement('p');
        price.className = 'card-text menu-price';
        price.textContent = `$${item.price ? item.price.toFixed(2) : '0.00'}`;
        cardBody.appendChild(price);
        const desc = document.createElement('p');
        desc.className = 'card-text';
        desc.textContent = item.description || '';
        cardBody.appendChild(desc);
        // Edit button
        const editBtn = document.createElement('button');
        editBtn.textContent = 'Edit';
        editBtn.className = 'btn btn-primary me-2';
        editBtn.onclick = () => editDish(item);
        cardBody.appendChild(editBtn);
        // Delete button
        const deleteBtn = document.createElement('button');
        deleteBtn.textContent = 'Delete';
        deleteBtn.className = 'btn btn-danger';
        deleteBtn.onclick = () => deleteDish(item.id);
        cardBody.appendChild(deleteBtn);
        card.appendChild(cardBody);
        col.appendChild(card);
        list.appendChild(col);
      });
    });
}

function deleteDish(id) {
  fetch(API_MENU_URL, {
    method: 'DELETE',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ id: id })
  }).then(() => fetchOwnerMenu());
}

function editDish(item) {
  // Simple prompt-based edit for demo
  const newName = prompt('Edit dish name:', item.dish_name);
  const newPrice = prompt('Edit price:', item.price);
  const newDesc = prompt('Edit description:', item.description);
  const newAvailable = confirm('Should this dish be available?');
  if (newName && newPrice) {
    fetch(API_MENU_URL, {
      method: 'POST', // Should be PUT/PATCH in real API
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        id: item.id,
        dish_name: newName,
        price: parseFloat(newPrice),
        description: newDesc,
        available: newAvailable
      })
    }).then(() => fetchOwnerMenu());
  }
}

document.addEventListener('DOMContentLoaded', () => {
  fetchOwnerMenu();
  document.getElementById('owner-add-form').addEventListener('submit', function(e) {
    e.preventDefault();
    const data = {
      dish_name: document.getElementById('owner_dish_name').value,
      price: parseFloat(document.getElementById('owner_price').value),
      description: document.getElementById('owner_description').value,
      available: document.getElementById('owner_available').checked
    };
    fetch(API_MENU_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    }).then(() => {
      fetchOwnerMenu();
      document.getElementById('owner-add-form').reset();
    });
  });
});
