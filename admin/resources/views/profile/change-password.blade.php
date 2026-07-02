@extends('layouts.app')
@section('content')
    <div class="mt-3 container-fluid">
        <div class="row d-flex align-items-center h-100vh">
            <div class="col-md-8 m-auto">
                @role('admin|root')
                    <form action="{{ route('profile.change-password') }}" method="POST">
                        @csrf
                    @endrole
                    <div class="card shadow-sm">
                        <div class="card-header bg-custom py-2">
                            <h4 class="m-0 text-white">Change Password</h4>
                        </div>
                        <div class="card-body">
                            <div class="form-group">
                                <label class="mb-0">Current Password</label>
                                <input type="text" name="current_password" placeholder="Enter Current Password"
                                    class="form-control" value="{{ old('current_password') }}">
                                @error('current_password')
                                    <span class="text-danger">{{ $message }}</span>
                                @enderror
                            </div>
                            <div class="form-group">
                                <label class="mb-0">New Password</label>
                                <input type="text" name="password" placeholder="Enter New Password" class="form-control"
                                    value="{{ old('password') }}">
                                @error('password')
                                    <span class="text-danger">{{ $message }}</span>
                                @enderror
                            </div>
                            <div class="form-group mb-0">
                                <label class="mb-0">Confirm Password</label>
                                <input type="text" name="password_confirmation" placeholder="Enter Confirm Password"
                                    class="form-control">
                            </div>
                        </div>
                        <div class="card-footer bg-white d-flex justify-content-between py-2">
                            <a href="{{ url()->previous() }}" class="btn btn-danger">Back</a>
                            <button class="btn btn-custom" type="submit">Save And Update</button>
                        </div>
                    </div>
                    @role('admin|root')
                    </form>
                @endrole
            </div>
        </div>
    </div>
@endsection
