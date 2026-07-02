@extends('layouts.app')

@push('title')
<div class="page-title-box">
    <h4 class="page-title">Dashboard</h4>
    <ol class="breadcrumb">
        <li class="breadcrumb-item active">Welcome to Maditam admin panel !</li>
    </ol>
</div>
@endpush

@section('content')
<div class="row">

    <div class="col-sm-6 col-lg-4 col-xl-3 animate__animated animate__fadeInLeftBig">
        <div class="mini-stat clearfix bx-shadow">
            <span class="mini-stat-icon bg-danger">
                <!-- <i class="fa fa-user"></i> -->
                <img src="/assets/icons/users.svg" alt="" 
                style="object-fit: contain; height: 32px;">
        </span>
            <div class="mini-stat-info text-end text-muted">
                <span class="countfect text-danger" data-num="{{ $users }}"></span>
                Total Users
            </div>
        </div>
    </div>

    <div class="col-sm-6 col-lg-4 col-xl-3 animate__animated animate__fadeInRight">
        <div class="mini-stat clearfix bx-shadow">
            <span class="mini-stat-icon bg-purple">
                <!-- <i class="fi-layers"></i> -->
                <img src="/assets/icons/categories.svg" alt="" 
                style="object-fit: contain; height: 26px;">
        </span>
            <div class="mini-stat-info text-end text-muted">
                <span class="countfect text-purple" data-num="{{ $categories }}"></span>
                Total Categories
            </div>
        </div>
    </div>

    <div class="col-sm-6 col-lg-4 col-xl-3 animate__animated animate__fadeInRightBig">
        <div class="mini-stat clearfix bx-shadow">
            <span class="mini-stat-icon bg-primary">
                <!-- <i class="fi-command"></i> -->
                <img src="/assets/icons/album.svg" alt="" 
                style="object-fit: contain; height: 26px;">
            </span>
            <div class="mini-stat-info text-end text-muted">
                <span class="countfect text-primary" data-num="{{ $albams }}"></span>
                Total Albums
            </div>
        </div>
    </div>

    <div class="col-sm-6 col-lg-4 col-xl-3 animate__animated animate__fadeInRightBig">
        <div class="mini-stat clearfix bx-shadow">
            <span class="mini-stat-icon" style="background-color: #15BE9C">
                <!-- <i class="fi-bar-graph-2"></i> -->
                <img src="/assets/icons/music.svg" alt="" 
                style="object-fit: contain; height: 26px;">
        </span>
            <div class="mini-stat-info text-end text-muted">
                <span class="countfect" style="color: #15BE9C" data-num="{{ $playLists }}"></span>
                Total Playlists
            </div>
        </div>
    </div>

    <div class="col-xl-6 mb-3 animate__animated animate__fadeInUp animate__delay-1s">
        <div class="card rounded-8">
            <div class="card-body">
                <div class="title d-flex justify-content-between align-items-center">
                    <h3 class="m-0">Latest Users</h3>
                    <a href="{{ route('user.index') }}">View All</a>
                </div>

                <div class="table-responsive mt-3">
                    <table class="table table-bordered table-striped">
                        <thead>
                            <tr>
                                <th>SL</th>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Phone</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach ($latest_users as $key => $user)
                            <tr>
                                <td>{{ $key + 1 }}</td>
                                <td>{{ $user->name }}</td>
                                <td>{{ $user->email }}</td>
                                <td>
                                    <img src="{{ $user->thumbnail }}" alt="" width="40" height="40">
                                </td>
                            </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <div class="col-xl-6 mb-3 animate__animated animate__fadeInUp animate__delay-2s">
        <div class="card rounded-8">
            <div class="card-body">
                <div class="title d-flex justify-content-between align-items-center">
                    <h3 class="m-0">Latest Categories</h3>
                    <a href="{{ route('category.index') }}">View All</a>
                </div>

                <div class="table-responsive mt-3">
                    <table class="table table-bordered table-striped">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Thumbnail</th>
                                <th>Icon</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach ($latest_category as $category)
                            <tr>
                                <td>{{ $category->name }}</td>
                                <td>
                                    <img src="{{ $category->thumbnail }}" alt="" width="50" height="50">
                                </td>
                                <td>
                                    <img src="{{ $category->iconPath }}" alt="" width="40" height="40">
                                </td>
                                <td>
                                    @if ($category->status)
                                    <span class="badge badge-pill badge-success">Active</span>
                                    @else
                                    <span class="badge badge-pill badge-danger">inactive</span>
                                    @endif
                                </td>
                            </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <div class="col-12 mb-3 animate__animated animate__fadeInUp animate__delay-2s">
        <div class="card rounded-8">
            <div class="card-body">
                <div class="title d-flex justify-content-between align-items-center">
                    <h3 class="m-0">Latest Playlist</h3>
                    <a href="{{ route('playlist.index') }}">View All</a>
                </div>

                <div class="table-responsive mt-3">
                    <table class="table table-bordered table-striped">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Duration</th>
                                <th>Audio File</th>
                                <th>Thumbnail</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach ($latest_playlist as $playlist)
                            <tr>
                                <td>{{ $playlist->name }}</td>
                                <td>{{ $playlist->duration }}</td>
                                <td>
                                    <audio controls>
                                        <source src="{{ $playlist->audioFile }}">
                                    </audio>
                                </td>
                                <td>
                                    <img src="{{ $playlist->thumbnail }}" alt="" width="50" height="50">
                                </td>
                            </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@push('scripts')
<script>
    var js = @json($week_number);
    var weekLable = @json($week_category);
    var options = {
        series: [{
            name: 'Users',
            data: js,
            color: '#3fb0a5'
        }],
        chart: {
            height: 320,
            type: 'area',
            toolbar: {
                show: false
            }
        },
        dataLabels: {
            enabled: false
        },
        stroke: {
            curve: 'smooth'
        },
        xaxis: {
            type: 'string',
            categories: weekLable
        },
        tooltip: {
            x: {
                format: 'dd/MM/yy'
            },
        },
    };

    var chart = new ApexCharts(document.querySelector("#dailyUsers"), options);
    chart.render();
</script>
@endpush