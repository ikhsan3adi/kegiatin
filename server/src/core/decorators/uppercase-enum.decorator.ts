import { Transform } from 'class-transformer';

/**
 * Transforms an incoming string value to uppercase before enum validation.
 * Apply before `@IsEnum()` to accept case-insensitive input.
 *
 * @example
 * @UppercaseEnum()
 * @IsEnum(EventType)
 * type: EventType;
 */
export const UppercaseEnum = () =>
  Transform(({ value }) =>
    typeof value === 'string' ? value.toUpperCase() : value,
  );
