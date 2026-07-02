@extends('layouts.app')

@push('title')
    <div class="page-title-box">
        <h4 class="page-title">Dashboard Categories</h4>
        <ol class="breadcrumb">
            <li class="breadcrumb-item active">All dashboard categorys list</li>
        </ol>
    </div>
@endpush

@section('content')
    <div class="card card-body mb-2">
        <div class="table-responsive">
            <table class="table table-bordered">
                <thead>
                    <tr>
                        <th scope="col">Type</th>
                        <th class="text-center">Status</th>
                        <th class="text-center">Album</th>
                        <th class="text-center">Action</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($shifts as $shift)
                        <tr>
                            <td class="text-capitalize">{{ $shift->type }}</td>
                            <td class="text-center">
                                <label class="switch">
                                    @role('root|admin')
                                    <a href="{{ route('shift.status.toggle', $shift->id) }}">
                                    @else
                                    <a href="javascript:void(0)">
                                    @endrole
                                        <input type="checkbox" {{ $shift->status ? 'checked' : '' }}>
                                        <span class="slider round"></span>
                                    </a>
                                </label>
                            </td>
                            <td class="text-center">
                                <button class="btn btn-info btn-sm" data-toggle="modal"
                                    data-target="#categoryAlbamId{{ $shift->id }}">albums</button>
                            </td>
                            <td style="min-width: 145px">
                                <div class="d-flex flex-wrap justify-content-center gap-4">
                                <a href="{{ route('shift.tree', $shift->id) }}" class="btn btn-secondary btn-sm" data-toggle="tooltip"
                                    title="Create"> <i class="fa fa-tree"></i></a>
                            </div>
                            </td>
                        </tr>

                        <!-- Modal -->
                        <div class="modal fade" id="categoryAlbamId{{ $shift->id }}">
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

                                            @foreach ($shift->albams as $albam)
                                                <div class="ModalColumn">
                                                   <div>
                                                    <img src="{{ $albam->thumbnail }}" alt="thumbnail" width="50">
                                                   </div>
                                                    <span>{{ $albam->name }}</span>
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
@endsection
