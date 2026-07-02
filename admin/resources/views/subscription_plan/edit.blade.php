@extends('layouts.app')

@push('title')
    <div class="page-title-box">
        <h4 class="page-title">Subscription Plan Edit</h4>
        <ol class="breadcrumb">
            <li class="breadcrumb-item active">Edit subscription plan</li>
        </ol>
    </div>
@endpush

@section('content')
    <div class="card card-body">
        @role('root|admin')
        <form action="{{ route('subscriptionPlan.update', $subscriptionPlan->id) }}" method="POST"
            enctype="multipart/form-data">
            @csrf
            @endrole
            <div class="row">
                <div class="col-12 text-center mb-2">
                    <img src="{{ $subscriptionPlan->thumbnail }}" alt="" width="120">
                </div>
                <div class="col-lg-6">
                    <x-input name="name" type="text" placeholder="Category Name"
                        value="{{ $subscriptionPlan->name }}">
                    </x-input>
                </div>

                <div class="col-lg-6">
                    <x-input-file name="thumbnail" placeholder="Thumbnail"></x-input-file>
                </div>

                <div class="col-lg-6">
                    <div class="form-group">
                        <label class="mb-1">Amount</label>
                        <input type="text" name="amount" class="form-control @error('amount') is-invalid @enderror"
                            placeholder="Amount" value="{{ $subscriptionPlan->amount }}" onkeypress="onlyNumber(event)">
                        @error('amount')
                            <small class="text-danger">{{ $message }}</small>
                        @enderror
                    </div>
                </div>
                <div class="col-lg-6">
                    <x-input name="duration" type="text" placeholder="Duration"
                        value="{{ $subscriptionPlan->duration }}">
                    </x-input>
                </div>

                <div class="col-lg-6">
                    <x-textarea name="feature_1" placeholder="Feature 1" value="{{ $subscriptionPlan->feature_1 }}" rows="2"></x-textarea>
                </div>

                <div class="col-lg-6">
                    <x-textarea name="feature_2" placeholder="Feature 2" value="{{ $subscriptionPlan->feature_2 }}" rows="2"></x-textarea>
                </div>

                <div class="col-lg-6">
                    <x-textarea name="feature_3" placeholder="Feature 3" value="{{ $subscriptionPlan->feature_3 }}" rows="2"></x-textarea>
                </div>

                <div class="col-lg-6">
                    <x-textarea name="feature_4" placeholder="Feature 4" value="{{ $subscriptionPlan->feature_4 }}" rows="2"></x-textarea>
                </div>

                <div class="col-lg-6">
                    <x-select name="is_recommended" placeholder="Is Recommended?">
                            <option value="1" {{ $subscriptionPlan->is_recommended == 1 ? 'selected' : '' }}> Yes </option>
                            <option value="0" {{ $subscriptionPlan->is_recommended == 0 ? 'selected' : '' }}> No </option>
                    </x-select>
                </div>

            </div>
            <div class="mt-3 d-flex justify-content-between">
                <a href="{{ route('subscriptionPlan.index') }}" type="button" class="btn btn-secondary text-white">GO
                    Back</a>
                <button type="submit" class="btn btn-success px-md-4">Save And Update</button>
            </div>
        </form>
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
