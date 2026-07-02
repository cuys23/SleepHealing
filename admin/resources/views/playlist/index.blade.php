@extends('layouts.app')

@push('title')
    <div class="page-title-box">
        <h4 class="page-title">playlists</h4>
        <ol class="breadcrumb">
            <li class="breadcrumb-item active">All playlists list</li>
        </ol>
    </div>
@endpush

@section('content')
    <div class="mb-2 d-flex justify-content-between align-items-center">
        <form action="" method="GET" class="d-flex" style="gap:4px">
            <input type="search" name="search" class="form-control" placeholder="Search by playlist name" value="{{ request()->search }}" style="height: 41px;min-width: 220px" />
            <button class="btn btn-primary btn-sm rounded"><i class="fa fa-search"></i> Search</button>
        </form>
        <a href="{{ route('playlist.create') }}" class="btn btn-custom">
            <i class="fa fa-plus"></i> Create New
        </a>
    </div>

    <div class="card card-body mb-2">
        <div class="table-responsive">
            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th scope="col">Name</th>
                        <th scope="col">Duration</th>
                        <th class="text-center">Status</th>
                        <th class="text-center">Paid</th>
                        <th class="text-center">Albums</th>
                        <th class="text-center">Action</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($playlists as $playlist)
                        <tr>
                            <td>{{ $playlist->name }}</td>
                            <td>{{ $playlist->duration }}min</td>
                            <td class="text-center">
                                <label class="switch">
                                    @role('root|admin')
                                        <a href="{{ route('playlist.status.toggle', $playlist->id) }}">
                                    @else
                                        <a href="javascript:void(0)">
                                    @endrole
                                        <input type="checkbox" {{ $playlist->status ? 'checked' : '' }}>
                                        <span class="slider round"></span>
                                    </a>
                                </label>
                            </td>
                            <td class="text-center">
                                <label class="switch">
                                    @role('root|admin')
                                        <a href="{{ route('playlist.paid.toggle', $playlist->id) }}">
                                    @else
                                        <a href="javascript:void(0)">
                                    @endrole
                                        <input type="checkbox" {{ $playlist->is_paid ? 'checked' : '' }}>
                                        <span class="slider round"></span>
                                    </a>
                                </label>
                            </td>
                            <td class="text-center" style="width: 110px">
                               <button class="btn btn-primary btn-sm" data-toggle="modal"
                               data-target="#albamId{{ $playlist->id }}">Albums</button>
                            </td>
                            <td style="width: 220px">
                                <div class="d-flex flex-wrap justify-content-between gap-4">
                                <a href="{{ route('playlist.show', $playlist->id) }}" class="btn btn-primary btn-sm " data-toggle="tooltip"
                                    title="Details"><i class="fa fa-eye"></i></a>
                                <a href="{{ route('playlist.edit', $playlist->id) }}" class="btn btn-info btn-sm" data-toggle="tooltip"
                                    title="Edit"><i class="fa fa-edit" ></i></a>
                                <a href="{{ route('playlist.readmore', $playlist->id) }}" class="btn btn-success btn-sm" data-toggle="tooltip"
                                    title="Read more"><i class="fa fa-book"></i></a>
                                 @role('root|admin')
                                    <a href="{{ route('playlist.delete', $playlist->id) }}" class="btn btn-danger btn-sm delete-confirm" data-toggle="tooltip"
                                    title="Delete"><i class="fa fa-trash"></i></a>
                                 @else
                                    <a href="javascript:void(0)" class="btn btn-danger btn-sm delete-confirm" data-toggle="tooltip"
                                    title="Delete"><i class="fa fa-trash"></i></a>
                                 @endrole
                                </div>
                            </td>
                        </tr>
                        <!-- Modal -->
                        <div class="modal fade" id="albamId{{ $playlist->id }}">
                            <div class="modal-dialog modal-dialog-scrollable modal-lg">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title">Album list</h5>
                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                            <span aria-hidden="true">&times;</span>
                                        </button>
                                    </div>
                                    <div class="modal-body">
                                        <div class="d-flex flex-column" style="gap: 8px">

                                            <div class="ModalColumn">
                                                <div>Thumbnail</div>
                                                <span>Name</span>
                                            </div>

                                            @forelse ($playlist->albams as $albam)
                                                <div class="ModalColumn">
                                                    <div>
                                                        <img src="{{ $albam->thumbnail }}" alt="thumbnail"
                                                            width="50" loading="lazy"/>
                                                    </div>
                                                    <span>{{ $albam->name }}</span>
                                                </div>
                                            @empty
                                            <div class="ModalColumn">
                                                <div class="text-muted">No data found</div>
                                            </div>
                                            @endforelse

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
        {{ $playlists->withQueryString()->links() }}
    </div>
@endsection
