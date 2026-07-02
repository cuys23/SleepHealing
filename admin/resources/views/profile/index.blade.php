@extends('layouts.app')

@section('content')
    <div class="mt-3 container-fluid">
        <div class="row d-flex align-items-center h-100vh">
            <div class="col-md-8 m-auto">
                <div class="card" style="border-radius: 8px">
                    <div class="card-body d-flex justify-content-between">
                        <div class="d-flex flex-wrap">
                            <div>
                                <img src="{{ $user->thumbnail }}" width="130">
                            </div>
                            <div>
                                <h3>{{ $user->name }}</h3>
                                <p>{{ $user->email }}</p>
                            </div>
                        </div>
                        <div>
                            <a href="{{ route('profile.edit') }}" class="btn btn-custom btn-sm">edit</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>
@endsection
