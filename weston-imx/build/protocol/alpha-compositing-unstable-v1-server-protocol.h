/* Generated by wayland-scanner 1.18.0 */

#ifndef ALPHA_COMPOSITING_UNSTABLE_V1_SERVER_PROTOCOL_H
#define ALPHA_COMPOSITING_UNSTABLE_V1_SERVER_PROTOCOL_H

#include <stdint.h>
#include <stddef.h>
#include "wayland-server.h"

#ifdef  __cplusplus
extern "C" {
#endif

struct wl_client;
struct wl_resource;

/**
 * @page page_alpha_compositing_unstable_v1 The alpha_compositing_unstable_v1 protocol
 * Protocol for more advanced compositing and blending
 *
 * @section page_desc_alpha_compositing_unstable_v1 Description
 *
 * This protocol specifies a set of interfaces used to control the alpha
 * compositing and blending of surface contents.
 *
 * Warning! The protocol described in this file is experimental and backward
 * incompatible changes may be made. Backward compatible changes may be added
 * together with the corresponding interface version bump. Backward
 * incompatible changes are done by bumping the version number in the protocol
 * and interface names and resetting the interface version. Once the protocol
 * is to be declared stable, the 'z' prefix and the version number in the
 * protocol and interface names are removed and the interface version number is
 * reset.
 *
 * @section page_ifaces_alpha_compositing_unstable_v1 Interfaces
 * - @subpage page_iface_zwp_alpha_compositing_v1 - alpha_compositing
 * - @subpage page_iface_zwp_blending_v1 - blending interface to a wl_surface
 * @section page_copyright_alpha_compositing_unstable_v1 Copyright
 * <pre>
 *
 * Copyright 2016 The Chromium Authors.
 * Copyright 2017 Collabora Ltd
 * Copyright 2018 NXP
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice (including the next
 * paragraph) shall be included in all copies or substantial portions of the
 * Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 * </pre>
 */
struct wl_surface;
struct zwp_alpha_compositing_v1;
struct zwp_blending_v1;

/**
 * @page page_iface_zwp_alpha_compositing_v1 zwp_alpha_compositing_v1
 * @section page_iface_zwp_alpha_compositing_v1_desc Description
 *
 * The global interface exposing compositing and blending capabilities is
 * used to instantiate an interface extension for a wl_surface object.
 * This extended interface will then allow the client to specify the
 * blending equation and alpha value used for compositing the wl_surface.
 * @section page_iface_zwp_alpha_compositing_v1_api API
 * See @ref iface_zwp_alpha_compositing_v1.
 */
/**
 * @defgroup iface_zwp_alpha_compositing_v1 The zwp_alpha_compositing_v1 interface
 *
 * The global interface exposing compositing and blending capabilities is
 * used to instantiate an interface extension for a wl_surface object.
 * This extended interface will then allow the client to specify the
 * blending equation and alpha value used for compositing the wl_surface.
 */
extern const struct wl_interface zwp_alpha_compositing_v1_interface;
/**
 * @page page_iface_zwp_blending_v1 zwp_blending_v1
 * @section page_iface_zwp_blending_v1_desc Description
 *
 * An additional interface to a wl_surface object, which allows the
 * client to specify the blending equation used for compositing and
 * an alpha value applied to the whole surface.
 *
 * When the blending object is created its blending equation is
 * 'none' and its alpha is 1.0, i.e., it's inactive by default. Clients
 * can activate it by setting the blending equation and alpha value.
 *
 * If the wl_surface associated with the blending object is destroyed,
 * the blending object becomes inert.
 *
 * If the blending object is destroyed, the blending state is removed
 * from the wl_surface. The change will be applied on the next
 * wl_surface.commit.
 * @section page_iface_zwp_blending_v1_api API
 * See @ref iface_zwp_blending_v1.
 */
/**
 * @defgroup iface_zwp_blending_v1 The zwp_blending_v1 interface
 *
 * An additional interface to a wl_surface object, which allows the
 * client to specify the blending equation used for compositing and
 * an alpha value applied to the whole surface.
 *
 * When the blending object is created its blending equation is
 * 'none' and its alpha is 1.0, i.e., it's inactive by default. Clients
 * can activate it by setting the blending equation and alpha value.
 *
 * If the wl_surface associated with the blending object is destroyed,
 * the blending object becomes inert.
 *
 * If the blending object is destroyed, the blending state is removed
 * from the wl_surface. The change will be applied on the next
 * wl_surface.commit.
 */
extern const struct wl_interface zwp_blending_v1_interface;

#ifndef ZWP_ALPHA_COMPOSITING_V1_ERROR_ENUM
#define ZWP_ALPHA_COMPOSITING_V1_ERROR_ENUM
enum zwp_alpha_compositing_v1_error {
	/**
	 * the surface already has a blending object associated
	 */
	ZWP_ALPHA_COMPOSITING_V1_ERROR_BLENDING_EXISTS = 0,
};
#endif /* ZWP_ALPHA_COMPOSITING_V1_ERROR_ENUM */

/**
 * @ingroup iface_zwp_alpha_compositing_v1
 * @struct zwp_alpha_compositing_v1_interface
 */
struct zwp_alpha_compositing_v1_interface {
	/**
	 * unbind from the blending interface
	 *
	 * Informs the server that the client will not be using this
	 * protocol object anymore. This does not affect any other objects,
	 * blending objects included.
	 */
	void (*destroy)(struct wl_client *client,
			struct wl_resource *resource);
	/**
	 * extend surface interface for blending
	 *
	 * Instantiate an interface extension for the given wl_surface to
	 * provide surface blending. If the given wl_surface already has a
	 * blending object associated, the blending_exists protocol error
	 * is raised.
	 * @param id the new blending interface id
	 * @param surface the surface
	 */
	void (*get_blending)(struct wl_client *client,
			     struct wl_resource *resource,
			     uint32_t id,
			     struct wl_resource *surface);
};


/**
 * @ingroup iface_zwp_alpha_compositing_v1
 */
#define ZWP_ALPHA_COMPOSITING_V1_DESTROY_SINCE_VERSION 1
/**
 * @ingroup iface_zwp_alpha_compositing_v1
 */
#define ZWP_ALPHA_COMPOSITING_V1_GET_BLENDING_SINCE_VERSION 1

#ifndef ZWP_BLENDING_V1_BLENDING_EQUATION_ENUM
#define ZWP_BLENDING_V1_BLENDING_EQUATION_ENUM
/**
 * @ingroup iface_zwp_blending_v1
 * different blending equations for compositing
 *
 * Blending equations that can be used when compositing a surface.
 */
enum zwp_blending_v1_blending_equation {
	/**
	 * blending object is inactive
	 */
	ZWP_BLENDING_V1_BLENDING_EQUATION_NONE = 0,
	/**
	 * (one, zero)
	 */
	ZWP_BLENDING_V1_BLENDING_EQUATION_OPAQUE = 1,
	/**
	 * (one, one_minus_src_alpha)
	 */
	ZWP_BLENDING_V1_BLENDING_EQUATION_PREMULTIPLIED = 2,
	/**
	 * (src_alpha, one_minus_src_alpha)
	 */
	ZWP_BLENDING_V1_BLENDING_EQUATION_STRAIGHT = 3,
	/**
	 * (src_alpha, src_alpha)
	 */
	ZWP_BLENDING_V1_BLENDING_EQUATION_FROMSOURCE = 4,
};
#endif /* ZWP_BLENDING_V1_BLENDING_EQUATION_ENUM */

/**
 * @ingroup iface_zwp_blending_v1
 * @struct zwp_blending_v1_interface
 */
struct zwp_blending_v1_interface {
	/**
	 * remove blending from the surface
	 *
	 * The associated wl_surface's blending state is removed. The
	 * change is applied on the next wl_surface.commit.
	 */
	void (*destroy)(struct wl_client *client,
			struct wl_resource *resource);
	/**
	 * set the blending equation
	 *
	 * Set the blending equation for compositing the wl_surface.
	 *
	 * The blending equation state is double-buffered state, and will
	 * be applied on the next wl_surface.commit.
	 * @param equation the new blending equation
	 */
	void (*set_blending)(struct wl_client *client,
			     struct wl_resource *resource,
			     uint32_t equation);
	/**
	 * set the alpha value
	 *
	 * Set the alpha value applied to the whole surface for
	 * compositing.
	 *
	 * The alpha value state is double-buffered state, and will be
	 * applied on the next wl_surface.commit.
	 * @param value the new alpha value
	 */
	void (*set_alpha)(struct wl_client *client,
			  struct wl_resource *resource,
			  wl_fixed_t value);
};


/**
 * @ingroup iface_zwp_blending_v1
 */
#define ZWP_BLENDING_V1_DESTROY_SINCE_VERSION 1
/**
 * @ingroup iface_zwp_blending_v1
 */
#define ZWP_BLENDING_V1_SET_BLENDING_SINCE_VERSION 1
/**
 * @ingroup iface_zwp_blending_v1
 */
#define ZWP_BLENDING_V1_SET_ALPHA_SINCE_VERSION 1

#ifdef  __cplusplus
}
#endif

#endif