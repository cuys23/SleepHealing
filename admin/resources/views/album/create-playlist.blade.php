@extends('layouts.app')

@push('title')
    <div class="page-title-box">
        <h4 class="page-title">Create Playlist</h4>
        <ol class="breadcrumb">
            <li class="breadcrumb-item active">Create new Playlist</li>
        </ol>
    </div>
@endpush

@section('content')
    <div class="row">
        <div class="col-md-10 m-auto">
            @role('root|admin')
            <form action="{{ route('albam.tree.update', $albam->id) }}" method="POST">
                @csrf
                @endrole
                <div class="card card-body">

                    <div class="max-height-scroll">
                        <div class="table-responsive">
                            <table class="table table-bordered table-striped treeTable">
                                <thead>
                                <tr>
                                    <th style="width: 50px" class="text-center"><input type="checkbox" onclick="toggle(this)">
                                    </th>
                                    <th>Playlist Name</th>
                                    <th>Duration</th>
                                    <th>Thumbnail</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach ($playlists as $playlist)
                                    <tr>
                                        <td class="text-center">

                                            <input type="checkbox" name="playlists[]" {{ in_array($playlist->id,$selectPlaylists ) ? 'checked' : '' }} value="{{ $playlist->id }}">
                                        </td>
                                        <td>
                                            {{ $playlist->name }}
                                        </td>
                                        <td>
                                            {{ $playlist->duration }} m
                                        </td>
                                        <td>
                                            <img src="{{ $playlist->thumbnail }}" alt="thumbnail" width="50" height="50">
                                        </td>
                                    </tr>
                                @endforeach
                            </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="d-flex justify-content-between mt-3">
                        <a href="{{ route('albam.index') }}" class="btn btn-secondary">Back</a>
                        <button type="submit" class="btn btn-primary px-4">Submit</button>
                    </div>
                </div>
            @role('root|admin')</form>@endrole
        </div>
    </div>
@endsection

@push('scripts')
    <script>
        function toggle(source) {
            var checkboxes = document.querySelectorAll('input[type="checkbox"]');
            for (var i = 0; i < checkboxes.length; i++) {
                if (checkboxes[i] != source)
                    checkboxes[i].checked = source.checked;
            }
        }

        $(document).ready( function () {
            $('#dataTable').DataTable({
                "ordering": false
            });
        } );
    </script>
@endpush
