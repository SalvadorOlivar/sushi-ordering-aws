document.addEventListener('DOMContentLoaded', function() {
    const cart = JSON.parse(localStorage.getItem('cart')) || [];
    const tbody = document.getElementById('checkout-products');
    tbody.innerHTML = '';
    let subtotal = 0;
    cart.forEach(product => {
        const total = product.precio * product.cantidad;
        subtotal += total;
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>${product.nombre} x${product.cantidad}</td>
            <td>$${total}</td>
        `;
        tbody.appendChild(tr);
    });

    // Actualizar subtotal, shipping y total en la tabla de resumen
    // Busca la tabla de resumen (tbody.checkout-details)
    const resumen = document.querySelectorAll('.checkout-details td');
    if (resumen.length >= 6) {
        // Subtotal
        resumen[1].innerText = `$${subtotal}`;
        // Shipping (fijo, puedes cambiarlo si lo deseas)
        const shipping = 50;
        resumen[3].innerText = `$${shipping}`;
        // Total
        resumen[5].innerText = `$${subtotal + shipping}`;
    }
});
