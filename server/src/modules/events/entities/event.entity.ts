import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';
import { EventType, EventStatus, EventVisibility } from '../domain/event.types';

@Schema({ timestamps: true, collection: 'events' })
export class EventEntity extends Document {
  @Prop({ required: true })
  title: string;

  @Prop({ type: String, default: '' })
  description: string;

  @Prop({ type: String, enum: EventType, required: true })
  type: EventType;

  @Prop({ type: String, enum: EventStatus, default: EventStatus.DRAFT })
  status: EventStatus;

  @Prop({ type: String, enum: EventVisibility, required: true })
  visibility: EventVisibility;

  @Prop({ type: String, default: '' })
  location: string;

  @Prop({ type: String, default: '' })
  contactPerson: string;

  @Prop({ type: String, default: null })
  imageUrl: string | null;

  @Prop({ type: Types.ObjectId, ref: 'UserEntity', required: true })
  createdBy: Types.ObjectId;

  createdAt: Date;
  updatedAt: Date;
}

export const EventSchema = SchemaFactory.createForClass(EventEntity);
