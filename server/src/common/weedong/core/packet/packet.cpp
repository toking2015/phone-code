#include "packet.h"

packet_t* packet_alloc(size_t length)
{
	if (length == 0)
		return NULL;

	packet_t* packet = (packet_t*) malloc(sizeof(packet_t));
	memset(packet, 0, sizeof(packet_t));
	packet->buf = (char*) malloc(length);
	memset(packet->buf, 0, length);
	packet->max_size = length;

	return packet;
}

int packet_join(packet_t* p, const void* in_data, size_t in_max_size)
{
	if (0 == p || 0 == in_data || 0 == in_max_size)
		return -1;

	if (p->write_offset + in_max_size > p->max_size)
		return -1;

	memcpy(&p->buf[p->write_offset], in_data, in_max_size);
	p->write_offset += in_max_size;

	return in_max_size;
}

int packet_join_struct(packet_t* p, const void* in_data, size_t in_max_size)
{
	if (0 == p || 0 == in_data)
		return -1;

	if (p->write_offset + in_max_size + sizeof(short) > p->max_size)
		return -1;

	*(short*)&p->buf[p->write_offset] = in_max_size;
	p->write_offset += sizeof(short);
	memcpy(&p->buf[p->write_offset], in_data, in_max_size);
	p->write_offset += in_max_size;

	return in_max_size;
}

int packet_take(packet_t* p, void* out_data, size_t out_max_size)
{
	if (0 == p || 0 == out_data)
		return -1;

	if (p->read_offset + out_max_size > p->max_size)
		return -1;

	memcpy(out_data, &p->buf[p->read_offset], out_max_size);
	p->read_offset += out_max_size;
	return out_max_size;
}

int packet_take_struct(packet_t* p, void* out_data, size_t out_max_size)
{
	if (0 == p || 0 == out_data)
		return -1;

	if (p->read_offset + sizeof(short) > p->max_size)
		return -1;

	short in_size = *(short*)&p->buf[p->read_offset];

	if (in_size >= out_max_size)
		return -1;

	p->read_offset += sizeof(short);

	if (p->read_offset + in_size > p->max_size)
		return -1;

	memcpy(out_data, &p->buf[p->read_offset], in_size);
	p->read_offset += in_size;
	return in_size;
}

void packet_dispose(packet_t* p)
{
	if (0 == p)
		return;

	free(p->buf);
	free(p);
}

packet_t* packet_pack(const void* in_data, size_t in_max_size)
{
	if (0 == in_data || 0 == in_max_size)
		return 0;

	packet_t* packet = packet_alloc(in_max_size);
	packet_join(packet, in_data, in_max_size);
	return packet;
}