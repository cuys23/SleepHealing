@extends('layouts.app')

@push('title')
    <div class="page-title-box">
        <h4 class="page-title">Albums</h4>
        <ol class="breadcrumb">
            <li class="breadcrumb-item active">All album list</li>
        </ol>
    </div>
@endpush

@section('content')
    <div class="mb-2 d-flex justify-content-between align-items-center">
        <form action="" method="GET" class="d-flex" style="gap:4px">
            <input type="search" name="search" class="form-control" placeholder="Search by album name"
                value="{{ request()->search }}" style="height: 40px;min-width: 220px" />
            <button class="btn btn-primary btn-sm rounded"><i class="fa fa-search"></i> Search</button>
        </form>
        <a href="{{ route('albam.create') }}" class="btn btn-custom"><i class="fa fa-plus"></i> Create New</a>
    </div>

    <div class="card card-body mb-2">
        <div class="table-responsive">
            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th scope="col">Photo</th>
                        <th scope="col">Name</th>
                        <th scope="col">Description</th>
                        <th class="text-center">Status</th>
                        <th class="text-center">Paid</th>
                        <th class="text-center">Playlist</th>
                        <th class="text-center">Action</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($albams as $albam)
                        <tr>
                            <td class="text-center">
                                <img src="{{ $albam->thumbnail }}" alt="" width="70" height="70"
                                    loading="lazy">
                            </td>
                            <td>{{ $albam->name }}</td>
                            <td style="max-width: 25em">{{ $albam->description }}</td>
                            <td class="text-center">
                                <label class="switch">
                                    @role('root|admin')
                                        <a href="{{ route('albam.status.toggle', $albam->id) }}">
                                        @else
                                            <a href="javascript:void(0)">
                                            @endrole
                                            <input type="checkbox" {{ $albam->status ? 'checked' : '' }}>
                                            <span class="slider round"></span>
                                        </a>
                                </label>
                            </td>
                            <td class="text-center">
                                <label class="switch">
                                    @role('root|admin')
                                        <a href="{{ route('albam.paid.toggle', $albam->id) }}">
                                        @else
                                            <a href="javascript:void(0)">
                                            @endrole
                                            <input type="checkbox" {{ $albam->is_paid ? 'checked' : '' }}>
                                            <span class="slider round"></span>
                                        </a>
                                </label>
                            </td>
                            <td class="text-center">
                                <button class="btn btn-info btn-sm" data-toggle="modal"
                                    data-target="#albamPlaylistId{{ $albam->id }}">Playlists</button>
                            </td>
                            <td style="min-width: 145px">
                                <div class="d-flex flex-wrap justify-content-center gap-4">
                                    <button class="btn btn-info btn-sm" data-toggle="modal" data-target="#categoryId{{ $albam->id }}">Categories</button>
                                    <a href="{{ route('albam.edit', $albam->id) }}" class="btn btn-info btn-sm" data-toggle="tooltip"
                                    title="Edit">
                                        <i class="fa fa-edit"></i>
                                    </a>
                                    @role('root|admin')
                                        <a href="{{ route('albam.delete', $albam->id) }}"
                                            class="btn btn-danger btn-sm delete-confirm" data-toggle="tooltip"
                                    title="Delete">
                                            <i class="fa fa-trash"></i>
                                        </a>
                                    @else
                                        <a href="javascript:void(0)" class="btn btn-danger btn-sm delete-confirm" data-toggle="tooltip"
                                    title="Delete">
                                            <i class="fa fa-trash"></i>
                                        </a>
                                    @endrole
                                    <a href="{{ route('albam.tree', $albam->id) }}" class="btn btn-secondary btn-sm" data-toggle="tooltip"
                                    title="Create">
                                        <i class="fa fa-tree"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>

                        <!-- Modal -->
                        <div class="modal fade" id="albamPlaylistId{{ $albam->id }}">
                            <div class="modal-dialog modal-dialog-scrollable modal-lg">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title">Play list</h5>
                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                            <span aria-hidden="true">&times;</span>
                                        </button>
                                    </div>
                                    <div class="modal-body">
                                        <div class="d-flex flex-column" style="gap: 8px">

                                            <div class="ModalColumn justify-content-between">
                                                <span>Thumbnail</span>
                                                <div>Name</div>
                                                <span>Duration</span>
                                            </div>

                                            @foreach ($albam->playlists as $playlist)
                                                <div class="ModalColumn justify-content-between">
                                                    <img src="{{ $playlist->thumbnail }}" alt="thumbnail" width="50"
                                                        loading="lazy">
                                                    <div>{{ $playlist->name }}</div>
                                                    <span>{{ $playlist->duration }}</span>
                                                </div>
                                            @endforeach

                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Modal -->
                        <div class="modal fade" id="categoryId{{ $albam->id }}">
                            <div class="modal-dialog modal-dialog-scrollable modal-lg">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title">Category list</h5>
                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                            <span aria-hidden="true">&times;</span>
                                        </button>
                                    </div>
                                    <div class="modal-body">
                                        <div class="d-flex flex-column" style="gap: 8px">

                                            <div class="ModalColumn justify-content-between">
                                                <span>Thumbnail</span>
                                                <div>Name</div>
                                            </div>

                                            @foreach ($albam->categories as $category)
                                                <div class="ModalColumn justify-content-between">
                                                    <img src="{{ $category->thumbnail }}" alt="thumbnail" width="50"
                                                        loading="lazy">
                                                    <div>{{ $category->name }}</div>
                                                </div>
                                            @endforeach

                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
    <div class="d-flex justify-content-end">
        {{ $albams->withQueryString()->links() }}
    </div>
@endsection
