import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';
import { SessionStatus } from '../domain/event.types';

@Schema({ timestamps: true, collection: 'sessions' })
export class SessionEntity extends Document {
  @Prop({ required: true })
  title: string;

  @Prop({ required: true })
  startTime: Date;

  @Prop({ required: true })
  endTime: Date;

  @Prop({ type: String, default: null })
  location: string | null;

  @Prop({ type: Number, default: null })
  capacity: number | null;

  @Prop({ required: true })
  order: number;

  @Prop({ type: String, enum: SessionStatus, default: SessionStatus.SCHEDULED })
  status: SessionStatus;

  @Prop({ type: Types.ObjectId, ref: 'EventEntity', required: true })
  eventId: Types.ObjectId;

  createdAt: Date;
  updatedAt: Date;
}

export const SessionSchema = SchemaFactory.createForClass(SessionEntity);
