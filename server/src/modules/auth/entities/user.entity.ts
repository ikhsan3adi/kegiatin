import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';
import { UserRole } from '../domain/user.types';

@Schema({ timestamps: true, collection: 'users' })
export class UserEntity extends Document {
  @Prop({ required: true, unique: true, lowercase: true, trim: true })
  email: string;

  @Prop({ required: true, select: false })
  password: string;

  @Prop({ required: true })
  displayName: string;

  @Prop({ type: String, enum: UserRole, default: UserRole.MEMBER })
  role: UserRole;

  @Prop({ type: String, default: null })
  npa: string | null;

  @Prop({ type: String, default: null })
  cabang: string | null;

  @Prop({ type: String, default: null })
  photoUrl: string | null;

  @Prop({ default: false })
  emailVerified: boolean;

  @Prop({ type: String, default: null, select: false })
  refreshTokenHash: string | null;

  createdAt: Date;
  updatedAt: Date;
}

export const UserSchema = SchemaFactory.createForClass(UserEntity);
