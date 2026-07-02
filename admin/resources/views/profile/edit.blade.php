@extends('layouts.app')

@section('content')
    <div class="mt-3 container-fluid">
        <div class="row">
            <div class="col-md-8 col-lg-6 m-auto">
                <div class="card">
                    @role('admin|root')
                        <form action="{{ route('profile.update') }}" method="POST" enctype="multipart/form-data">
                        @endrole
                        <div class="card-body">
                            @csrf
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label>Full Name</label>
                                        <input class="form-control" type="text" name="name"
                                            value="{{ $user->name }}">
                                    </div>
                                </div>

                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label>Email Address</label>
                                        <input class="form-control" type="text" name="email"
                                            value="{{ $user->email }}">
                                    </div>
                                </div>
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label>Profile Photo</label>
                                        <input class="form-control-file" type="file" name="profile_photo">
                                    </div>
                                </div>

                            </div>
                        </div>
                        <div class="card-footer bg-white d-flex justify-content-between">
                            <a href="{{ url()->previous() }}" class="btn btn-danger">Back</a>
                            <button class="btn btn-primary" type="submit">Update</button>
                        </div>
                        @role('admin|root')
                        </form>
                    @endrole
                </div>
            </div>
        </div>

    </div>
@endsection
