<div class="form-group">
    <label class="mb-1">{{ $placeholder }}</label>
    <textarea name="{{ $name }}" class="form-control" rows="{{ $rows }}" placeholder="{{ $placeholder }}">{{ $value }}</textarea>
    @error($name)
        <small class="text-danger">{{ $message }}</small>
    @enderror
</div>
