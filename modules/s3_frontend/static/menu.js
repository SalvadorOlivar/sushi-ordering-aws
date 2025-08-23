// Sushi images for demo
const SUSHI_IMAGES = [
  "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80",
  "https://images.unsplash.com/photo-1467003909585-2f8a72700288?auto=format&fit=crop&w=400&q=80",
  "https://images.unsplash.com/photo-1519864600265-abb23847ef2c?auto=format&fit=crop&w=400&q=80",
  "https://images.unsplash.com/photo-1502741338009-cac2772e18bc?auto=format&fit=crop&w=400&q=80",
  "https://images.unsplash.com/photo-1523987355523-c7b5b0723c36?auto=format&fit=crop&w=400&q=80"
];

const API_MENU_URL = 'https://l6h6mdzou7.execute-api.us-east-1.amazonaws.com/test/v1/menu';
const API_ORDERS_URL = 'https://l6h6mdzou7.execute-api.us-east-1.amazonaws.com/test/v1/orders';

function fetchMenu() {
  fetch(API_MENU_URL)
    .then(res => res.json())
    .then(data => {
      const list = document.getElementById('menu-list');
      list.innerHTML = '';
      data.forEach((item, idx) => {
        const col = document.createElement('div');
        col.className = 'col-md-4 d-flex';
        const card = document.createElement('div');
        card.className = 'card h-100 shadow-sm w-100';
        const img = document.createElement('img');
        img.src = SUSHI_IMAGES[idx % SUSHI_IMAGES.length];
        img.alt = item.dish_name;
        img.className = 'card-img-top menu-img';
        card.appendChild(img);
        const cardBody = document.createElement('div');
        cardBody.className = 'card-body text-center d-flex flex-column';
        const title = document.createElement('h5');
        title.className = 'card-title';
        title.textContent = item.dish_name;
        cardBody.appendChild(title);
        const price = document.createElement('p');
        price.className = 'card-text menu-price';
        price.textContent = `$${item.price ? item.price.toFixed(2) : '0.00'}`;
        cardBody.appendChild(price);
        const orderBtn = document.createElement('button');
        orderBtn.textContent = 'Order';
        orderBtn.className = 'btn btn-warning order-btn mt-auto';
        orderBtn.onclick = () => createOrder(item.id);
        cardBody.appendChild(orderBtn);
        card.appendChild(cardBody);
        col.appendChild(card);
        list.appendChild(col);
      });
    });
}

function createOrder(menuId) {
  // Demo: hardcoded user info, in real app get from session or form
  const order = {
    customer_name: "Salvador Olivar",
    address: "Av Brasil 2420",
    phone: "+1234567890",
    items: [menuId],
    total: 0 // You may want to fetch price or calculate in backend
  };
  fetch(API_ORDERS_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(order)
  })
    .then(res => res.json())
    .then(resp => {
      alert('Order placed! ' + (resp.message || ''));
    })
    .catch(() => alert('Error placing order.'));
}

document.addEventListener('DOMContentLoaded', () => {
  fetchMenu();
  document.getElementById('add-form').addEventListener('submit', function(e) {
    e.preventDefault();
    const data = {
      dish_name: document.getElementById('dish_name').value,
      price: parseFloat(document.getElementById('price').value),
      description: document.getElementById('description').value,
      available: document.getElementById('available').checked
    };
    fetch(API_MENU_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    }).then(() => {
      fetchMenu();
      document.getElementById('add-form').reset();
    });
  });
});
