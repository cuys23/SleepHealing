@extends('layouts.app')

@push('title')
    <div class="page-title-box">
        <h4 class="page-title">App Slider</h4>
        <ol class="breadcrumb">
            <li class="breadcrumb-item active">App slider list</li>
        </ol>
    </div>
@endpush

@section('content')
    <div class="mb-3 d-flex justify-content-end">
        <a href="{{ route('banner.create') }}" class="btn btn-custom"><i class="fa fa-plus"></i> Create New</a>
    </div>
    <div class="card card-body mb-2">
        <div class="table-responsive">
            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th style="width: 120px" class="text-center">Thumbnail</th>
                        <th scope="col">Title</th>
                        <th scope="col">Description</th>
                        <th class="text-center">Status</th>
                        <th class="text-center">Action</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($banners as $banner)
                        <tr>
                            <td class="text-center">
                                <img src="{{ $banner->thumbnail }}" alt="" width="110">
                            </td>
                            <td>{{ $banner->title }}</td>
                            <td>{{ $banner->description }}</td>
                            <td class="text-center">
                                <label class="switch">
                                    @role('root|admin')
                                        <a href="{{ route('banner.status.toggle', $banner->id) }}">
                                    @else
                                        <a href="javascript:void(0)">
                                    @endrole
                                        <input type="checkbox" {{ $banner->status ? 'checked' : '' }}>
                                        <span class="slider round"></span>
                                    </a>
                                </label>
                            </td>
                            <td>
                                <div class="d-flex flex-wrap justify-content-center gap-4">
                                <a href="{{ route('banner.edit', $banner->id) }}" class="btn btn-info btn-sm"><i
                                        class="fa fa-edit"></i></a>
                                @role('root|admin')
                                    <a href="{{ route('banner.delete', $banner->id) }}"
                                        class="btn btn-danger btn-sm delete-confirm"><i class="fa fa-trash"></i>
                                    </a>
                                @else
                                    <a href="javascript:void(0)" class="btn btn-danger btn-sm delete-confirm"><i class="fa fa-trash"></i>
                                    </a>
                                @endrole
                            </div>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
@endsection
