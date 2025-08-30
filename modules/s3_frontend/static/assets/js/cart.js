document.addEventListener('DOMContentLoaded', function() {
  const cart = JSON.parse(localStorage.getItem('cart')) || [];
  const tbody = document.getElementById('cart-body');
  tbody.innerHTML = '';
  let subtotal = 0;
  cart.forEach(product => {
    const total = product.precio * product.cantidad;
    subtotal += total;
    const tr = document.createElement('tr');
    tr.className = 'table-body-row';
    tr.innerHTML = `
      <td class="product-remove"><a href="#" class="remove-btn" data-id="${product.id}"><i class="far fa-window-close"></i></a></td>
      <td class="product-image"><img src="${product.img}" alt=""></td>
      <td class="product-name">${product.nombre}</td>
      <td class="product-price">$${product.precio}</td>
      <td class="product-quantity"><input type="number" value="${product.cantidad}" min="1" data-id="${product.id}" class="qty-input"></td>
      <td class="product-total">$${total}</td>
    `;
    tbody.appendChild(tr);
  });

  // Actualizar subtotal y total
  document.querySelectorAll('.total-data td').forEach(td => {
    if (td.innerText.includes('Subtotal')) {
      td.nextElementSibling.innerText = `$${subtotal}`;
    }
    if (td.innerText.includes('Total:')) {
      // Suponiendo shipping fijo de 45
      td.nextElementSibling.innerText = `$${subtotal + 45}`;
    }
  });

  // Eliminar producto
  tbody.addEventListener('click', function(e) {
    if (e.target.closest('.remove-btn')) {
      const id = parseInt(e.target.closest('.remove-btn').dataset.id);
      const newCart = cart.filter(p => p.id !== id);
      localStorage.setItem('cart', JSON.stringify(newCart));
      location.reload();
    }
  });

  // Cambiar cantidad
  tbody.addEventListener('change', function(e) {
    if (e.target.classList.contains('qty-input')) {
      const id = parseInt(e.target.dataset.id);
      const newQty = parseInt(e.target.value);
      const prod = cart.find(p => p.id === id);
      if (prod && newQty > 0) {
        prod.cantidad = newQty;
        localStorage.setItem('cart', JSON.stringify(cart));
        location.reload();
      }
    }
  });
});