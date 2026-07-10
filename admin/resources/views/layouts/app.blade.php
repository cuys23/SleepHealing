@php
    $websetting = App\Models\WebSetting::first();
@endphp
<!doctype html>
<html lang="en">

<head>
    <meta charset="utf-8" />
    <title>{{ $websetting->title ?? 'Maditam' }}</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />

    <link rel="shortcut icon" href="{{ $websetting?->favIconPath ?? asset('web/images/fav_icon.png') }}">

    <link href="{{ asset('web/css/bootstrap.min.css') }}" rel="stylesheet" type="text/css" />
    <link href="{{ asset('web/apexcharts/apexcharts.css') }}" rel="stylesheet" type="text/css" />
    <link href="{{ asset('web/css/icons.css') }}" rel="stylesheet" type="text/css" />
    <link href="{{ asset('web/css/metismenu.min.css') }}" rel="stylesheet" type="text/css" />
    <link href="{{ asset('web/css/sweetalert2.min.css') }}" rel="stylesheet" type="text/css" />
    <link href="{{ asset('web/css/animate.min.css') }}" rel="stylesheet" type="text/css" />
    <link href="{{ asset('web/css/style.css') }}" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/v/bs4/dt-1.13.2/datatables.min.css" />
</head>


<body>

    <div id="wrapper">

        <div class="left side-menu">

            <div class="slimscroll-menu" id="remove-scroll">

                <div class="topbar-left">
                    <a href="{{ route('root') }}" class="logo">
                        <span>
                            <img src="{{ $websetting?->logoPath ?? asset('web/images/logo.png') }}" alt="">
                        </span>
                    </a>
                </div>

                <div class="user-box">
                    {{-- <div class="user-img">
                        <img src="{{ auth()->user()->thumbnail }}" alt="user-img" title="Mat Helme"
                            class="rounded-circle img-fluid">
                    </div>
                    <h5><a href="#">{{ auth()->user()->name }}</a> </h5>
                    <p class="text-muted m-0">Admin Head</p> --}}
                </div>

                <!--- Sidemenu -->
                @include('layouts.sidebar')
                <!-- Sidebar -->

                <div class="clearfix"></div>

            </div>

        </div>

        <div class="content-page pt-0">

            <div class="topbar">

                <nav class="navbar-custom">

                    <ul class="list-unstyled topbar-right-menu float-right mb-0">

                        <li class="dropdown notification-list">
                            <a class="nav-link dropdown-toggle nav-user" data-toggle="dropdown" href="#"
                                role="button" aria-haspopup="false" aria-expanded="false">
                                <img src="{{ auth()->user()->thumbnail }}" alt="user" class="rounded-circle"> <span
                                    class="ml-1">{{ auth()->user()->name }} <i class="mdi mdi-chevron-down"></i>
                                </span>
                            </a>
                            <div class="dropdown-menu dropdown-menu-right dropdown-menu-animated profile-dropdown">

                                <a href="{{ route('profile.index') }}" class="dropdown-item notify-item">
                                    <i class="fa fa-user-circle-o"></i> <span>Profile</span>
                                </a>
                                <a href="{{ route('profile.change-password') }}" class="dropdown-item notify-item">
                                    <i class="fa fa-key"></i> <span>Change Password</span>
                                </a>

                                <a href="javascript:void(0);" class="dropdown-item notify-item logoutConfirm">
                                    <i class="fi-power"></i> <span>Logout</span>
                                </a>
                                <form id="logout" action="{{ route('logout') }}" method="POST"> @csrf </form>

                            </div>
                        </li>
                    </ul>

                    <ul class="list-inline menu-left mb-0">
                        <li class="float-left">
                            <button class="button-menu-mobile open-left disable-btn">
                                <i class="dripicons-menu"></i>
                            </button>
                        </li>
                        <li>
                            @stack('title')
                        </li>
                    </ul>

                </nav>

            </div>

            <div class="content">
                <div class="container-fluid">
                    @yield('content')
                </div>
            </div>

            <footer class="footer">
                ©{{ date('Y') . ' ' . ($websetting?->name ?? 'Maditam') }}. Developed by <a href="https://razinsoft.com/"
                    target="_blank">razinsoft.com</a>
            </footer>
        </div>

    </div>

    <!-- jQuery  -->
    <script src="{{ asset('web/js/jquery.min.js') }}"></script>
    <script src="{{ asset('web/js/bootstrap.bundle.min.js') }}"></script>
    <script src="{{ asset('web/apexcharts/apexcharts.min.js') }}"></script>
    <script src="{{ asset('web/js/metisMenu.min.js') }}"></script>
    <script src="{{ asset('web/js/jquery.slimscroll.js') }}"></script>
    <script src="{{ asset('web/js/jquery.app.js') }}"></script>
    <script src="{{ asset('web/js/sweetalert2.min.js') }}"></script>
    <script src="{{ asset('web/js/counterfect.js') }}"></script>
    <script type="text/javascript" src="https://cdn.datatables.net/v/bs4/dt-1.13.2/datatables.min.js"></script>
    @stack('scripts')
    <script>
        const Toast = Swal.mixin({
            toast: true,
            position: 'top-end',
            showConfirmButton: false,
            timer: 3000,
            timerProgressBar: true,
            didOpen: (toast) => {
                toast.addEventListener('mouseenter', Swal.stopTimer)
                toast.addEventListener('mouseleave', Swal.resumeTimer)
            }
        })
    </script>
    @if (session('success'))
        <script>
            Toast.fire({
                position: 'bottom-right',
                icon: 'success',
                title: '{{ session('success') }}'
            })
        </script>
    @endif

    @if (session('errors'))
        <script>
            Toast.fire({
                position: 'bottom-right',
                icon: 'warning',
                title: 'Something went wrong'
            })
        </script>
    @endif

    @if (session('warning'))
        <script>
            Toast.fire({
                position: 'bottom-right',
                icon: 'warning',
                title: '{{ session('warning') }}'
            })
        </script>
    @endif

    @if (session('error'))
        <script>
            Toast.fire({
                position: 'bottom-right',
                icon: 'warning',
                title: session('error')
            })
        </script>
    @endif

    <script>
        function showAlert(message) {
            Swal.fire({
                icon: 'error',
                title: 'Oops...',
                text: message,
            });
        }
        $('.logoutConfirm').on('click', function(e) {
            e.preventDefault();
            Swal.fire({
                title: 'Are you sure?',
                text: "Are you sure you want to log out?",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#00B894',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Yes, Logout!'
            }).then((result) => {
                if (result.isConfirmed) {
                    document.getElementById('logout').submit()
                }
            })
        });

        $('.delete-confirm').on('click', function(e) {
            e.preventDefault();
            const url = $(this).attr('href');
            Swal.fire({
                title: 'Are you sure?',
                text: "You won't be able to revert this!",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#00B894',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Yes, delete it!'
            }).then((result) => {
                if (result.isConfirmed) {
                    window.location.href = url;
                }
            })
        });
    </script>
    @role('visitor')
        <script>
            $(":submit").on('click', function(e) {
                Swal.fire(
                    'Access Denied!',
                    "You don't have permission to access update/edit this admin.",
                    'warning'
                )
            })
        </script>
    @endrole


<script>
  $(function () {
    $('[data-toggle="tooltip"]').tooltip();
  });
</script>
</body>

</html>
