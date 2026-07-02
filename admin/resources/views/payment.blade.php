<!doctype html>
<html lang="en">

<head>
    <title>Maditam Core Payment</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link
        href="https://fonts.googleapis.com/css2?family=Poppins:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap"
        rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet"
        integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/toastr.min.css" rel="stylesheet" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/toastr.min.js" defer></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>

    <style>
        .poppins-regular {
            font-family: "Poppins", sans-serif;
            font-weight: 400;
            font-style: normal;
        }

        .poppins-bold {
            font-family: "Poppins", sans-serif;
            font-weight: 700;
            font-style: normal;
        }

        .card:hover {
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.5);
            transform: scale(1.05);
            transition: all 0.3s ease-in-out;
        }
    </style>
</head>

<body class="bg-light">

    <header class="text-center p-4 bg-primary text-white mb-3">
        <h4 class="poppins-regular">Select Your Payment Method</h4>
    </header>
    <main class="container">
        <div class="row">
            <div class="col-6 mb-3">
                <div class="card border-0 shadow-sm">
                    <div class="card-body">
                        <div class="card-img py-3">
                            <img src="https://www.edigitalagency.com.au/wp-content/uploads/new-PayPal-Logo-horizontal-full-color-png.png"
                                alt="2checkout" width="150">
                        </div>
                        <h5 class="card-title poppins-bold">PayPal</h5>
                        <p class="card-text poppins-regular">
                            With supporting text below as a natural lead-in to additional content.
                        </p>
                        <a href="{{ route('payment', ['gateway' => 'paypal']) }}"
                            class="btn btn-primary poppins-bold">Pay with
                            PayPal</a>
                        <button type="button" class="btn border btn-sm poppins-regular" data-bs-toggle="modal"
                            data-bs-target="#modalId" data-method-name="PayPal"
                            data-method-description="With supporting text below as a natural lead-in to additional content.">
                            <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Infobox_info_icon.svg/640px-Infobox_info_icon.svg.png"
                                width="20" alt="">
                        </button>
                    </div>
                </div>
            </div>
            <div class="col-6">
                <div class="card border-0 shadow-sm">
                    <div class="card-body">
                        <div class="card-img">
                            <img src="https://1000logos.net/wp-content/uploads/2021/06/Stripe-Logo-2009.png"
                                alt="stripe" width="130">
                        </div>
                        <h5 class="card-title poppins-bold">Stripe</h5>
                        <p class="card-text poppins-regular">With supporting text below as a natural lead-in to
                            additional content.</p>
                        <a href="{{ route('payment', ['gateway' => 'stripe']) }}"
                            class="btn btn-primary poppins-bold">Pay with
                            Stripe</a>
                        <button type="button" class="btn border btn-sm poppins-regular" data-bs-toggle="modal"
                            data-bs-target="#modalId" data-method-name="Stripe"
                            data-method-description="With supporting text below as a natural lead-in to additional content.">
                            <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Infobox_info_icon.svg/640px-Infobox_info_icon.svg.png"
                                width="20" alt="">
                        </button>
                    </div>
                </div>
            </div>

            <div class="col-6 mb-3">
                <div class="card border-0 shadow-sm">
                    <div class="card-body">
                        <div class="card-img py-3">
                            <img src="https://seeklogo.com/images/1/2checkout-logo-D1E93B6D17-seeklogo.com.png"
                                alt="2checkout" width="150">
                        </div>
                        <h5 class="card-title poppins-bold">2Checkout</h5>
                        <p class="card-text poppins-regular">With supporting text below as a natural lead-in to
                            additional content.</p>
                        <a href="{{ route('payment', ['gateway' => '2checkout']) }}"
                            class="btn btn-primary poppins-bold">Pay with
                            2Checkout</a>
                        <button type="button" class="btn border btn-sm poppins-regular" data-bs-toggle="modal"
                            data-bs-target="#modalId" data-method-name="2Checkout"
                            data-method-description="With supporting text below as a natural lead-in to additional content.">
                            <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Infobox_info_icon.svg/640px-Infobox_info_icon.svg.png"
                                width="20" alt="">
                        </button>
                    </div>
                </div>
            </div>

            <div class="col-6 mb-3">
                <div class="card border-0 shadow-sm">
                    <div class="card-body">
                        <div class="card-img py-3">
                            <img src="https://www.aamarpay.com/images/logo/aamarpay_logo.png" alt="2checkout"
                                width="150" height="55">
                        </div>
                        <h5 class="card-title poppins-bold">AamarPay</h5>
                        <p class="card-text poppins-regular">With supporting text below as a natural lead-in to
                            additional content.</p>
                        <a href="{{ route('payment', ['gateway' => 'aamarpay']) }}"
                            class="btn btn-primary poppins-bold">Pay with
                            AamarPay</a>
                        <button type="button" class="btn border btn-sm poppins-regular" data-bs-toggle="modal"
                            data-bs-target="#modalId" data-method-name="AamarPay"
                            data-method-description="With supporting text below as a natural lead-in to additional content.">
                            <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Infobox_info_icon.svg/640px-Infobox_info_icon.svg.png"
                                width="20" alt="">
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </main>
    <footer>
        <!-- place footer here -->
    </footer>

    <div class="modal fade" id="modalId" tabindex="-1" role="dialog" aria-labelledby="modalTitleId"
        aria-hidden="true">
        <div class="modal-dialog modal-dialog-scrollable modal-dialog-centered modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title poppins-bold" id="modalTitleId">Payment Method Info</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <h5 id="methodName" class="poppins-bold"></h5>
                    <p id="methodDescription" class="poppins-regular"></p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>


    <script>
        document.querySelectorAll('[data-bs-toggle="modal"]').forEach(item => {
            item.addEventListener('click', event => {
                const methodName = event.currentTarget.getAttribute('data-method-name');
                const methodDescription = event.currentTarget.getAttribute('data-method-description');
                document.getElementById('methodName').textContent = methodName;
                document.getElementById('methodDescription').textContent = methodDescription;
            });
        });
        document.addEventListener('DOMContentLoaded', function() {
            @if (session('success'))
                toastr.success('{{ session('success') }}');
            @endif

            @if (session('error'))
                toastr.error('{{ session('error') }}');
            @endif
        });
    </script>


    <!-- Bootstrap JavaScript Libraries -->
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js"
        integrity="sha384-I7E8VVD/ismYTF4hNIPjVp/Zjvgyol6VFvRkX/vR+Vc4jQkC+hVqc2pM8ODewa9r" crossorigin="anonymous">
    </script>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.min.js"
        integrity="sha384-BBtl+eGJRgqQAUMxJ7pMwbEyER4l1g+O15P+16Ep7Q9Q+zqX6gSbd85u4mG4QzX+" crossorigin="anonymous">
    </script>
</body>

</html>
