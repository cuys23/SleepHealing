@extends('layouts.app')

@push('title')
    <div class="page-title-box">
        <h4 class="page-title">App Users</h4>
        <ol class="breadcrumb">
            <li class="breadcrumb-item active">All app users list</li>
        </ol>
    </div>
@endpush

@section('content')
    <div class="card card-body mb-2 animate__animated animate__fadeIn">
           <form action="" >
            <div class="d-flex justify-content-end mb-2" style="gap: 4px">
                <input class="form-control" type="search" name="search" placeholder="Search By name or email" style="max-width: 300px">
                <button class="btn btn-custom py-2">Search</button>
            </div>
           </form>
        <div class="table-responsive">
            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th scope="col">SL.</th>
                        <th scope="col">User Name</th>
                        <th scope="col">Email</th>
                        <th class="text-center">Status</th>
                        <th class="text-center">Action</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($users as $index => $user)
                        <tr>
                            @php
                                $serial = \request()->page ? (\request()->page - 1) * 10 : 0;
                            @endphp
                            <th scope="row">{{ sprintf('%04s', $serial + $index + 1) }}</th>
                            <td>{{ $user->name }}</td>
                            <td>{{ $user->email }}</td>
                            <td class="text-center">
                                <label class="switch">
                                    @role('admin|root')
                                        <a href="{{ route('user.status.toggle', $user->id) }}">
                                    @else
                                        <a href="javascript:void(0)">
                                    @endrole
                                        <input type="checkbox" {{ $user->status ? 'checked' : '' }}>
                                        <span class="slider round"></span>
                                    </a>
                                </label>
                            </td>
                            <td class="text-center">
                                <a href="{{ route('user.show', $user->id) }}" class="btn btn-primary btn-sm"><i
                                    class="fa fa-eye"></i></a>
                                <a href="{{ route('user.edit', $user->id) }}" class="btn btn-info btn-sm"><i
                                    class="fa fa-pencil"></i></a>
                            {{-- <a href="{{ route('user.delete', $user->id) }}" class="btn btn-danger btn-sm delete-confirm"><i
                                        class="fa fa-trash"></i></a> --}}
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>

    <div class="d-flex justify-content-end flex-wrap">
        {{ $users->links() }}
    </div>
@endsection
