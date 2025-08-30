let allMenus = [];
let currentPage = 1;
const itemsPerPage = 9;

document.addEventListener('DOMContentLoaded', function() {
  fetch('menu.json') 
    .then(response => response.json())
    .then(menuItems => {
      allMenus = menuItems; // Guardar los datos
      renderMenuPage(currentPage); // Mostrar la primera página
      renderPagination(); // Mostrar la paginación
    })
    .catch(error => console.error('Error cargando el menú:', error));
});

function renderMenuPage(page) {
    const container = document.getElementById('product-lists');
    container.innerHTML = '';
    const start = (page - 1) * itemsPerPage;
    const end = start + itemsPerPage;
    const pageMenus = allMenus.slice(start, end);
  pageMenus.forEach(item => {
    container.innerHTML += `
      <div class="col-lg-4 col-md-6 text-center">
        <div class="single-product-item">
          <div class="product-image">
            <a href="single-product.html?id=${item.id}">
              <img src="${item.image}" alt="">
            </a>
          </div>
          <h3>${item.name}</h3>
          <p class="product-price"><span>Porción</span> ${item.price}$ </p>
          <a href="#" class="cart-btn" data-id="${item.id}">
            <i class="fas fa-shopping-cart"></i> Agregar al carrito
          </a>
        </div>
      </div>
    `;
  });
}

function renderPagination() {
    const paginationWrap = document.querySelector('.pagination-wrap ul');
    if (!paginationWrap) return;
    paginationWrap.innerHTML = '';

    const totalPages = Math.ceil(allMenus.length / itemsPerPage);

    // Prev button
    paginationWrap.innerHTML += `<li><a href="#" class="page-link" data-page="${currentPage - 1}" ${currentPage === 1 ? 'style="pointer-events:none;opacity:0.5;"' : ''}>Prev</a></li>`;

    // Page numbers
    for (let i = 1; i <= totalPages; i++) {
        paginationWrap.innerHTML += `<li><a href="#" class="page-link ${i === currentPage ? 'active' : ''}" data-page="${i}">${i}</a></li>`;
    }

    // Next button
    paginationWrap.innerHTML += `<li><a href="#" class="page-link" data-page="${currentPage + 1}" ${currentPage === totalPages ? 'style="pointer-events:none;opacity:0.5;"' : ''}>Next</a></li>`;

    // Add click listeners
    document.querySelectorAll('.page-link').forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const page = parseInt(this.getAttribute('data-page'));
            if (page >= 1 && page <= totalPages) {
                currentPage = page;
                renderMenuPage(currentPage);
                renderPagination();
            }
        });
    });
}

function addToCart(product) {
  let cart = JSON.parse(localStorage.getItem('cart')) || [];
  // Buscar si ya existe el producto
  const found = cart.find(item => item.id === product.id);
  if (found) {
    found.cantidad += 1;
  } else {
    cart.push({ ...product, cantidad: 1 });
  }
  localStorage.setItem('cart', JSON.stringify(cart));
}

// Delegación de eventos para botones "Agregar al carrito"
document.addEventListener('click', function(e) {
  if (e.target.closest('.cart-btn')) {
    e.preventDefault();
    const btn = e.target.closest('.cart-btn');
    const id = parseInt(btn.getAttribute('data-id'));
    const product = allMenus.find(item => item.id === id);
    if (product) {
      addToCart({
        id: product.id,
        nombre: product.name,
        precio: product.price,
        img: product.image
      });
      alert('Producto agregado al carrito');
    }
  }
});