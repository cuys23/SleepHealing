<div>
    <div class="form-group">
        <label class="mb-1" for="{{ $name }}">{{ $placeholder }}</label>
        <input type="{{ $type }}" name="{{ $name }}" class="form-control @error($name) is-invalid @enderror" id="{{ $name }}" placeholder="{{ $placeholder }}" value="{{ old($name, $value) }}">
        @error($name)
        <small class="text-danger">{{ $message }}</small>
        @enderror
    </div>
</div>
