@extends('layouts.app')

@push('title')
    <div class="page-title-box">
        <h4 class="page-title">Subscription Plan Create</h4>
        <ol class="breadcrumb">
            <li class="breadcrumb-item active">Create new subscription plan</li>
        </ol>
    </div>
@endpush

@section('content')
    <div class="card card-body">
        @role('root|admin')
            <form action="{{ route('subscriptionPlan.store') }}" method="POST" enctype="multipart/form-data">
                @csrf
            @endrole
            <div class="row">
                <div class="col-lg-6">
                    <x-input name="name" type="text" placeholder="Name" value=""></x-input>
                </div>

                <div class="col-lg-6">
                    <x-input-file name="thumbnail" placeholder="Thumbnail"></x-input-file>
                </div>

                <div class="col-lg-6">
                    <x-input name="amount" type="number" placeholder="Amount" value=""></x-input>
                </div>
                <div class="col-lg-6">
                    <x-input name="duration" type="text" placeholder="Duration" value=""></x-input>
                </div>

                <div class="col-lg-6">
                    <x-textarea name="feature_1" placeholder="Feature 1" value="" rows="2"></x-textarea>
                </div>

                <div class="col-lg-6">
                    <x-textarea name="feature_2" placeholder="Feature 2" value="" rows="2"></x-textarea>
                </div>

                <div class="col-lg-6">
                    <x-textarea name="feature_3" placeholder="Feature 3" value="" rows="2"></x-textarea>
                </div>

                <div class="col-lg-6">
                    <x-textarea name="feature_4" placeholder="Feature 4" value="" rows="2"></x-textarea>
                </div>
                <div class="col-lg-6">
                    <x-select name="is_recommended" placeholder="Is Recommended?">
                            <option value="1"> Yes </option>
                            <option value="0"> No </option>
                    </x-select>
                </div>
            </div>

            <div class="mt-3 d-flex justify-content-between">
                <a href="{{ route('subscriptionPlan.index') }}" type="button" class="btn btn-secondary text-white">GO
                    Back</a>
                <button type="submit" class="btn btn-success px-md-5">Submit</button>
            </div>
            @role('root|admin')
            </form>
        @endrole
    </div>
@endsection
@push('scripts')
    <script>
        function onlyNumber(evt) {
            var chars = String.fromCharCode(evt.which);
            if (!(/[0-9.]/.test(chars))) {
                evt.preventDefault();
            }
        }
    </script>
@endpush
