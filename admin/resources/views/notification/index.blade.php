@extends('layouts.app')

@section('content')
    <div class="container-fluid mt-4">
        <div class="row">
            <div class="col-md-9 col-lg-8 m-auto">
                <form action="{{ route('notification.send') }}" method="POST">
                    @csrf
                    <div class="card">
                        <div class="card-header bg-custom">
                            <h4 class="card-title m-0 text-white">Send Notifications</h4>
                        </div>
                        <div class="card-body">
                            <div class="form-group">
                                <label class="mb-1">Title</label>
                                <input name="title" class="form-control" rows="4"
                                    placeholder="Notification Title..." />
                                @error('title')
                                    <span class="text-danger">{{ $message }}</span>
                                @enderror
                            </div>
                            <div class="form-group mb-2">
                                <label class="mb-1">Message</label>
                                <textarea name="message" class="form-control" rows="4" placeholder="Notification Message..."></textarea>
                                @error('message')
                                    <span class="text-danger">{{ $message }}</span>
                                @enderror
                            </div>
                            <div class="d-flex justify-content-end mt-2">
                                <button type="submit" class="btn btn-custom px-4">Send Message</button>
                            </div>
                        </div>
                    </div>


                    <div class="card mt-3">
                        <div class="card-body">

                            <div class="d-flex justify-content-start align-items-end flex-wrap mb-3" style="gap: 10px">
                                <div style="width: 200px">
                                    <label class="font-weight-normal font-14 m-0">Select Device Type:</label>
                                    <select id="deviceType" class="form-control">
                                        <option value="all">All</option>
                                        <option value="android">Android</option>
                                        <option value="ios">Ios</option>
                                    </select>
                                </div>
                                <div style="width: 200px">
                                    <label class="font-weight-normal font-14 m-0">Select User</label>
                                    <select id="userType" class="form-control">
                                        <option value="all">All</option>
                                        <option value="free">Free</option>
                                        <option value="premium">Premium</option>
                                    </select>
                                </div>
                                <button id="filterUsers" class="btn btn-custom px-4" type="button">Filters</button>
                            </div>

                            @error('customer')
                                <small class="text-danger">{{ $message }}</small>
                            @enderror
                            <div class="table-responsive-md maxScroll mt-2">
                                <table class="table table-bordered table-striped" id="myTable">
                                    <thead>
                                        <tr>
                                            <th class="px-0 text-center" style="width: 42px">
                                                <input type="checkbox" onclick="toggle(this);" />
                                            </th>
                                            <th>User Name</th>
                                            <th>User Email</th>
                                        </tr>
                                    </thead>
                                    <tbody id="notificationUsers">
                                        @foreach ($users as $user)
                                            <tr>
                                                <td class="py-2 px-0 text-center">
                                                    <input type="checkbox" name="user[]" value="{{ $user->id }}">
                                                </td>
                                                <td class="py-2">{{ $user->name }}</td>
                                                <td>{{ $user->email }}</td>
                                            </tr>
                                        @endforeach
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
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
        };

        $(document).ready(function() {
            $("#filterUsers").click(function(e) {
                var userType = $('#userType').val();
                var deviceType = $('#deviceType').val();
                if (userType == '') {
                    alert('Please select user type');
                } else {
                    $.ajax({
                        type: 'GET',
                        url: "{{ route('notification.filter') }}",
                        dataType: 'json',
                        data: {
                            user_type: userType,
                            device_type: deviceType
                        },
                        success: function(response) {
                            $('#notificationUsers').empty()
                            $.each(response.data.users, function(key, value) {
                                $('#notificationUsers').append(
                                    "<tr>\
                                        <td> <input type='checkbox' name='user[]' value='" + value.id + "'></td>\
                                        <td>" + value.name + "</td>\
                                        <td>" + value.email + "</td>\
                                    </tr>"
                                );
                            })
                            if (!response.data.users.length) {
                                $('#notificationUsers').append(
                                    "<tr>\
                                        <td colspan='3'> User list is empty</td>\
                                    </tr>"
                                );
                            }
                        },
                        error: function(e) {
                            $('#notificationUsers').empty()
                            $("#notificationUsers").html(e.responseText);
                        }
                    });
                }
            });
        });
    </script>
@endpush
